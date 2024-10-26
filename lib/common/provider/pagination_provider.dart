import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/model/model_with_id.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/pagination_params.dart';
import '../repository/base_pagination_repository.dart';

class _PaginationInfo {
  final int fetchCount;
  final bool fetchMore; // true: 추가로 데이터 더 가져오기, false: 새로고침(현재 상태를 덮어씌움)
  final bool forceRefetch; // 강제로

  _PaginationInfo({
    this.fetchCount = 20,
    this.fetchMore = false,
    this.forceRefetch = false,
  });
}

class PaginationProvider<T extends IModelWithId,
        U extends IBasePaginationRepository<T>>
    extends StateNotifier<CursorPaginationBase> {
  // T 타입은 페이지네이션에서 가져오는 실제 데이터의 타입

  final U repository;
  final paginationThrottle = Throttle(
    Duration(seconds: 3),
    initialValue: _PaginationInfo(),
    checkEquality: false, // 실행할 떄마다 스로틀이 걸리길 원한다.
  );

  PaginationProvider({
    required this.repository,
  }) : super(CursorPaginationLoading()) {
    paginate();

    paginationThrottle.values.listen(
        (state) {
          _throttledPagination(state);
        }
    );
  }

  Future<void> paginate({
    int fetchCount = 20,
    bool fetchMore = false, // true: 추가로 데이터 더 가져오기, false: 새로고침(현재 상태를 덮어씌움)
    bool forceRefetch = false, // 강제로
    // 다시 로딩, true: CursorPaginationLoading()
  }) async {
    paginationThrottle.setValue(_PaginationInfo(
      fetchCount: fetchCount,
      fetchMore: fetchMore,
      forceRefetch: forceRefetch,
    ));
  }

  _throttledPagination(_PaginationInfo info) async {
    final fetchCount = info.fetchCount;
    final fetchMore = info.fetchMore;
    final forceRefetch = info.forceRefetch;

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
        // 이 if문을 지났다는 것은 state가 CursorPagination 이라는 것이다.

        final pState = state
        as CursorPagination; // as CursorPagination 무조건 이 타입일 경우에만 사용한다. 1%의 가능성이라고 있어서는 안 된다.

        // 더 데이터가 없다면
        if (!pState.meta.hasMore) {
          return; // hasMore가 false이면 이 paginate를 나가면 된다.
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
        count: fetchCount, // 넣지 않아도 되는데(서버에서 기본적으로 지정하는 경우) 혹시나 함수를 호출할 수 있으니까
      );

      // fetchMore
      // 데이터를 추가로 더 가져오는 상황
      // fetchMore를 실행할 수 있는 상황은 화면에 데이터가 보여지고 있는 상황, 무조건 데이터를 들고 있는 상황
      if (fetchMore) {
        // 데이터를 들고 있으니까 이게 된다 -> CursorPagination extend하거나, CursorPagination의 인스턴스라는 것을 확신
        final pState = state as CursorPagination<T>; // IModelWithId 덕분에 <T> 가능

        state = CursorPaginationFetchingMore(
          meta: pState.meta,
          data: pState.data,
        );

        paginationParams = paginationParams.copyWith(
          // IModelWithId 덕분에 '.' 찍으면 id 자동완성에 나온다.
          after: pState.data.last.id, // 마지막 데이터의 id,
        );
      }
      // 데이터를 처음부터 가져오는 상황
      else {
        // 만약 데이터가 있는 상황이라면, 기본 데이터를 보존한 채로 Fetch (API 요청)를 진행
        // state is CursorPagination : 데이터가 존재하는 상황, 자식 또는 인스턴스
        // forceRefetch : 완전히 처음부터 새로고침이므로 데이터가 있는 상황은 !forceRefetch
        if (state is CursorPagination && !forceRefetch) {
          // 데이터를 보여주다가 새롭게 대치되는 데이터를 유저에게 보여주는 게 앱이 빠르다는 느낌을 줌
          final pState = state as CursorPagination<T>;

          state = CursorPaginationRefetching<T>(
            meta: pState.meta,
            data: pState.data,
          );
        } else {
          // 나머지 상황
          state = CursorPaginationLoading();
        }
      }

      // 맨 처음 20개의 데이터를 가져오는 부분, after 값이 없으므로
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
        // 처음 가져온 데이터를 state에 넣어서 보여줌
        state = resp;
      }
    } catch (e, stack) {
      print(e);
      print(stack);
      state = CursorPaginationError(message: '데이터를 가져오지 못했습니다.');
    }
  }
}
