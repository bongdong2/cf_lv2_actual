import 'dart:convert';

import 'package:actual/common/const/colors.dart';
import 'package:actual/common/const/data.dart';
import 'package:actual/common/layout/default_layout.dart';
import 'package:actual/common/sercure_storage/sercure_storage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/component/custom_text_form_field.dart';
import '../../common/view/root_tab.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String username = '';
  String password = '';

  @override
  Widget build(BuildContext context) {
    final dio = Dio();

    return DefaultLayout(
      child: SingleChildScrollView(
        // 키보드가 UI 영역을 침범할 때 사용하자
        // 드래그하면 키보드 사라지게
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Title(),
                const SizedBox(
                  height: 16.0,
                ),
                _SubTitle(),
                Image.asset(
                  'asset/img/misc/logo.png',
                  width: MediaQuery.of(context).size.width / 3 * 2,
                ),
                CustomTextFormField(
                  hintText: '이메일을 입력하세요.',
                  onChanged: (String value) {
                    username = value;
                  },
                ),
                const SizedBox(
                  height: 8.0,
                ),
                CustomTextFormField(
                  hintText: '비밀번호를 입력하세요.',
                  onChanged: (String value) {
                    password = value;
                  },
                  obscureText: true,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ElevatedButton(
                    onPressed: () async {
                      final rawString = '$username:$password';

                      // <String, String> : String 값을 넣고 String을 반환 받겠다.
                      // Base64 값으로 인코딩
                      Codec<String, String> stringToBase64 = utf8.fuse(base64);
                      String token = stringToBase64.encode(rawString);

                      print('ip : $ip');

                      final resp = await dio.post(
                        'http://$ip/auth/login',
                        options: Options(headers: {
                          'authorization': 'Basic $token',
                        }),
                      );

                      final refreshToken = resp.data['refreshToken'];
                      final accessToken = resp.data['accessToken'];

                      final storage = ref.read(secureStorageProvider);

                      storage.write(
                          key: REFRESH_TOKEN_KEY, value: refreshToken);
                      storage.write(key: ACCESS_TOKEN_KEY, value: accessToken);

                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => RootTab()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_COLOR,
                    ),
                    child: const Text('로그인')),
                TextButton(
                    onPressed: () async {},
                    style: TextButton.styleFrom(foregroundColor: Colors.black),
                    child: const Text('회원가입'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '환영합니다.',
      style: TextStyle(
        fontSize: 34.0,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      '이메일과 비밀번호를 입력해서 로그인해주세요.\n오늘도 성공적인 주문이 되길 :)',
      style: TextStyle(
        fontSize: 16.0,
        color: BODY_TEXT_COLOR,
      ),
    );
  }
}
