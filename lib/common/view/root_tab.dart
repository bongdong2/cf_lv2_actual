import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/order/view/order_screen.dart';
import 'package:actual/product/view/product_screen.dart';
import 'package:actual/user/view/profile_screen.dart';
import 'package:flutter/material.dart';

import '../../restaurant/view/restaurant_screen.dart';
import '../const/colors.dart';

class RootTab extends StatefulWidget {
  static String get routeName => 'home';

  const RootTab({Key? key}) : super(key: key);

  @override
  State<RootTab> createState() => _RootTabState();
}

class _RootTabState extends State<RootTab> with SingleTickerProviderStateMixin { // 'vsync: this' 사용하기 위해 'with SingleTickerProviderStateMixin' 추가
  // late : controller를 사용할 때에는 선언 되었을 거야, '?' 사용하면 일일히 null check 해야 함
  late TabController controller;
  int index = 0;

  @override
  void initState() {
    super.initState();

    controller = TabController(length: 4, vsync: this); // vsync 애니메이션 관련
    controller.addListener(tabListener); // BottomNavigationBar 변경 리스너
  }

  @override
  void dispose() {
    controller.removeListener(tabListener); // super.dispose(); 전에 호출
    super.dispose();
  }

  void tabListener() {
    setState(() {
      index = controller.index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '메인 화면',
      child: TabBarView(
        physics: NeverScrollableScrollPhysics(), // TabBarView 좌우 스크롤 막기
        controller: controller,
        children: [
          RestaurantScreen(),
          ProductScreen(),
          OrderScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: PRIMARY_COLOR,
        unselectedItemColor: BODY_TEXT_COLOR,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (int index){
          controller.animateTo(index);
        },
        currentIndex: index,

        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
              ),
              label: '홈'
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.fastfood_outlined,
              ),
              label: '음식'
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.receipt_long_outlined
              ),
              label: '주문'
          ),
          BottomNavigationBarItem(
              icon: Icon(
                  Icons.person_outlined
              ),
              label: '프로필'
          ),
        ],
      ),
    );
  }
}
