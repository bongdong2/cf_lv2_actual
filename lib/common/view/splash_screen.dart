import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/common/sercure_storage/sercure_storage.dart';
import 'package:actual/common/view/root_tab.dart';
import 'package:actual/user/view/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../const/colors.dart';
import '../const/data.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    //deleteToken();
    // 에러 발생으로..
    Future.delayed(Duration.zero, () {
      checkToken();
    });
  }

  void deleteToken() async {
    final storage = ref.watch(secureStorageProvider);
    await storage.deleteAll();
  }

  void checkToken() async {
    final storage = ref.watch(secureStorageProvider);

    final refreshToken = await storage.read(key: REFRESH_TOKEN_KEY);

    try {
      // 여기서 refreshToken으로 로그인한다.
      final resp = await dio.post(
        'http://$ip/auth/token',
        options: Options(
            headers: {
              'authorization': 'Bearer $refreshToken',
            }
        ),
      );

      await storage.write(key: ACCESS_TOKEN_KEY, value: resp.data['accessToken']);
      print('Splash Screen > /auth/token > resp : $resp');

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute( builder: (_) => const RootTab())
          , (route) => false
      );

    } catch(e) {
      print('error catch : $e');

      // 에러가 있으면 로그인 스크린으로
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute( builder: (_) => const LoginScreen())
          , (route) => false
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      backgroundColor: PRIMARY_COLOR,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'asset/img/logo/logo.png',
              width: MediaQuery.of(context).size.width / 2,
            ),
            SizedBox(height: 16.0),
            CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
