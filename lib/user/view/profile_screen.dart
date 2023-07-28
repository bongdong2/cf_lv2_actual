import 'package:actual/user/provider/user_me_proivder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ElevatedButton(
        onPressed: (){
          ref.read(userMeProvider.notifier).logout();
        },
        child: Text('로그아웃'),
      ),
    );
  }
}
