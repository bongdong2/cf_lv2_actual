import 'package:actual/common/const/colors.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/common/provider/go_router.dart';
import 'package:actual/common/view/root_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderDoneScreen extends StatelessWidget {
  static String get routeName => 'orderDone';

  const OrderDoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.thumb_up_alt_outlined,
              color: PRIMARY_COLOR,
              size: 50.0,
            ),
            const SizedBox(
              height: 30.0,
            ),
            Text(
              '결제가 완료되었습니다.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
              onPressed: () {
                context.goNamed(RootTab.routeName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
              ),
              child: Text(
                '홈으로 가기',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
