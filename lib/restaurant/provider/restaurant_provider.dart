import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/provider/pagination_provider.dart';
import 'package:actual/restaurant/model/restaurant_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';

import '../repository/restaurant_repository.dart';

// Cache 데이터를 가져오기 위함
final restaurantDetailProvider =
    Provider.family<RestaurantModel?, String>((ref, id) {
  // provider에 id(상세정보)값을 넣어준다.
  final state =
      ref.watch(restaurantProvider); // restaurantProvider로부터 상태를 가져온다.
  // restaurantProvider의 상태가 변하면, restaurantDetailProvider도 변한다.

  // CursorPagination이 아니라는 뜻은 데이터가 restaurantProvider에 없다는 뜻, 그래서 null 반환
  if (state is! CursorPagination<RestaurantModel>) {
    return null;
  }

  // firstWhere 는 존재하지 않으면 에러를 발생시킴, 이는 우리가 원하는 바가 아님
  // collection 패키지 추가하면 firstWhereOrNull 사용 가능

  // restaurantProvider에서 가져온 restaurnat 목록의 id에 해당하는 레스토랑을 반환한다.
  return state.data.firstWhereOrNull((element) => element.id == id);
});

final restaurantProvider =
    StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  final notifier = RestaurantStateNotifier(repository: repository);
  return notifier;
});

class RestaurantStateNotifier
    extends PaginationProvider<RestaurantModel, RestaurantRepository> {
  // PaginationProvider 가 StateNotifier 를 extends 하기 때문에 RestaurantStateNotifier 도 extends 한다.

  RestaurantStateNotifier({
    required super.repository,
  });

  void getDetail({
    required String id,
  }) async {
    // 만약 아직 데이터가 하나도 없는 상태라면(CursorPagination이 아니라면)
    // 데이터를 가져오는 시도를 한다.
    if (state is! CursorPagination) {
      await this.paginate();
    }

    // 바로 위에서 paginate헀는데도 state가 CussorPagination이 아닐 때, 리턴
    // 뭔가 서버에서 에러가 발생했거나 장애가 있는 경우, 우리가 할 수 있는 게 없다.
    if (state is! CursorPagination) {
      return;
    }

    // 이제 여기까지 왔다면 state is CursorPagination 보장

    // restaurantModel
    final pState = state as CursorPagination;

    // restaurantDetailModel
    final resp = await repository.getRestaurantDetail(id: id);

    // pState를 rooping 면서 id가 getDetail의 파라미터 id와 같다면 pState를 resp(새로 가져온 데이터)로 대치해야 한다.

    // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)]
    // 요청 id: 10
    // list.where((e) => e.id == 10)) 데이터 없어서 에러 발생

    // 데이터가 없을 때는 그냥 캐시의 끝에다가 데이터를 추가해버린다.
    // [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3), RestaurantDetailModel(10)]
    if (pState.data.where((e) => e.id == id).isEmpty) {
      state = pState.copyWith(
        data: <RestaurantModel>[
          ...pState.data,
          resp,
        ],
      );
    } else {
      /*
      예를 들어
      [RestaurantModel(1), RestaurantModel(2), RestaurantModel(3)..]
      요청 id : 2인 친구를 Detail모델을 가져와라
      getDetail(id: 2);
      요청 후
      [RestaurantModel(1), RestaurantDetailModel(2), RestaurantModel(3)..]
      id : 2인 친구만 Detail 모델로 변경되었다.
      */
      state = pState.copyWith(
        data: pState.data
            .map<RestaurantModel>((e) => e.id == id ? resp : e)
            .toList(),
      );
    }
  }
}
