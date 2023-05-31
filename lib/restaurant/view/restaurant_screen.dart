import 'package:actual/restaurant/provider/restaurant_provider.dart';
import 'package:actual/restaurant/view/restaurant_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../component/restaurant_card.dart';

class RestaurantScreen extends ConsumerWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 이제 FutureBuilder 필요 없음
    final data = ref.watch(restaurantProvider);

    // 임시 예외처리
    if (data.length == 0) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          itemCount: data.length,
          itemBuilder: (_, index) {
            final pItem = data[index];

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RestaurantDetailScreen(
                      id: pItem.id,
                    ),
                  ),
                );
              },
              child: RestaurantCard.fromModel(
                model: pItem,
              ),
            );
          },
          separatorBuilder: (_, index) {
            return SizedBox(height: 16.0);
          },
        )
    );
  }
}
