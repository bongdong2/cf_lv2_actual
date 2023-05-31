import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/restaurant_repository.dart';

final restaurantProvider = StateNotifierProvider<RestaurantStateNotifier, CursorPaginationBase>((ref) {
  final repository = ref.watch(restaurantRepositoryProvider);
  final notifier = RestaurantStateNotifier(repository: repository);
  return notifier;
});

class RestaurantStateNotifier extends StateNotifier<CursorPaginationBase> {
  final RestaurantRepository repository;

  RestaurantStateNotifier({
    required this.repository,
  }) : super(CursorPaginationLoading()) { // 초기값을 로딩으로
    // RestaurantStateNotifier가 생성이 되는 순간 paginate 실행
    paginate();
  }

  paginate() async {
    final resp = await repository.paginate();

    state = resp;
  }
}
