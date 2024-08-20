import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/model_with_id.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/pagination_params.dart';
import '../repository/base_pagination_repository.dart';

class PaginationProvider<
T extends IModelWithId,
U extends IBasePaginationRepository<T>> extends StateNotifier<CursorPaginationBase> {
  final U repository;

  PaginationProvider({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    paginate();
  }

  Future<void> paginate({
    int fetchCount = 20,
    bool fetchMore = false, // true: 추가로 데이터 더 가져오기, false: 새로고침(현재 상태를 덮어씌움)
    bool forceRefetch = false, // 강제로 다시 로딩, true: CursorPaginationLoading()
  }) async {
    try {
      // State 상태가 5가지 가능성이 있다.
      // 1) CursorPagination : 정상적으로 데이터가 있는 상태
      // 2) CursorPaginationLoading : 데이터가 로딩 중인 상태(현재 캐시 없음)
      // 3) CursorPaginationError : 에러가 있는 상태
      // 4) CursorPaginationRefetching : 첫 번재 페이지부터 다시 데이터를 가져올 때
      // 5) CursorPaginationFetchMore : 추가 데이터를 paginate 하라는 요청을 받았을 때

      // 바로 반환하는 상황
      // 1) hasMore = false (기존 상태에서 이미 다음 데이터가 없다는 값을 들고 있다면)
      // 2) 로딩 중 - fetchMore : true
      //    fetchMore가 아닐 때 - 새로고침의 의도가 있을 수 있다.
      if (state is CursorPagination && !forceRefetch) {
        final pState = state as CursorPagination;

        // 더 데이터가 없다면
        if (!pState.meta.hasMore) {
          return;
        }
      }

      final isLoading = state is CursorPaginationLoading;
      final isRefetching = state is CursorPaginationRefetching;
      final isFetchingMore = state is CursorPaginationFetchingMore;

      // 2번 반환 상황
      if (fetchMore && (isLoading || isRefetching || isFetchingMore)) {
        return;
      }

      // PaginationParams 생성
      PaginationParams paginationParams = PaginationParams(
        count: fetchCount,
      );

      // fetchMore : 데이터를 더 가져오는 상황
      if (fetchMore) {
        final pState = state as CursorPagination<T>;

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          after: pState.data.last.id,
        );
      }
      // 데이터를 처음부터 가져오는 상황
      else {
        // 만약 데이터가 있는 상황이라면, 기본 데이터를 보존한 채로 Fetch (API 요청)를 진행
        if (state is CursorPagination && !forceRefetch) {
          final pState = state as CursorPagination<T>;

          state = CursorPaginationRefetching<T>(
            meta: pState.meta,
            data: pState.data,
          );
        }
        // 나머지 상황
        else {
          state = CursorPaginationLoading();
        }
      }

      // 맨 처음 20개의 데이터를 가져오는 부분
      final resp = await repository.paginate(
        paginationParams: paginationParams,
      );

      if (state is CursorPaginationFetchingMore) {
        final pState = state as CursorPaginationFetchingMore<T>;

        // 기존 데이터에 새 데이터 추가
        state = resp.copyWith(data: [
          ...pState.data, // 기존 데이터
          ...resp.data, // 새 데이터
        ]);
      } else {
        state = resp;
      }
    } catch (e, stack) {
      print(e);
      print(stack);
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }
}
