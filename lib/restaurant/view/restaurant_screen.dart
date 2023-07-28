import 'package:actual/common/model/cursor_pagination_model.dart';
import 'package:actual/common/utils/pagination_utils.dart';
import 'package:actual/restaurant/provider/restaurant_provider.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../component/restaurant_card.dart';

class RestaurantScreen extends ConsumerStatefulWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends ConsumerState<RestaurantScreen> {
  final ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();

    controller.addListener(scrollListener);
  }

  void scrollListener() {
    PaginationUtils.paginate(
      controller: controller,
      provider: ref.read(restaurantProvider.notifier),
    );
    // 현재 위치가 최대 길이보다 조금 덜 되는 위치까지 왔다면
    // 새로운 데이터를 추가 요청
    // if (controller.offset > controller.position.maxScrollExtent - 300) {
    //   ref.read(restaurantProvider.notifier).paginate(
    //         fetchMore: true,
    //       );
    // }
  }

  @override
  Widget build(BuildContext context) {
    // 이제 FutureBuilder 필요 없음
    final data = ref.watch(restaurantProvider);

    // 진짜 로딩일 때만 로딩을 보여주자. 완전 처음 로딩.
    if (data is CursorPaginationLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러
    if (data is CursorPaginationError) {
      return Center(
        child: Text(data.message),
      );
    }

    // 이 셋을 모두 meta, data값을 가지고 있다.
    // CursorPagination
    // CursorPaginationMore
    // CursorPaginationRefetching

    // 임시
    final cp = data as CursorPagination;

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          controller: controller,
          itemCount: cp.data.length + 1,
          itemBuilder: (_, index) {
            if (index == cp.data.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 32.0,
                ),
                child: Center(
                  child: data is CursorPaginationFetchingMore
                      ? CircularProgressIndicator()
                      : Text('마지막 데이터 입니다.'),
                ),
              );
            }

            final pItem = cp.data[index];

            return GestureDetector(
              onTap: () {
                //context.go('/restaurant/${pItem.id}');
                context.goNamed(RestaurantDetailScreen.routeName,
                pathParameters: {
                  'rid': pItem.id,
                });
              },
              child: RestaurantCard.fromModel(
                model: pItem,
              ),
            );
          },
          separatorBuilder: (_, index) {
            return SizedBox(height: 16.0);
          },
        ));
  }
}
