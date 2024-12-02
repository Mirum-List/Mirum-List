// lib/main.dart

import 'package:flutter/material.dart';
import 'package:mirum_list/authentication/sign_in_screen.dart';
import 'package:mirum_list/home/main_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mirum_list/const/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mirum List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: deepBlueColor,
        // 추가적인 테마 설정 가능
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 인증 상태를 확인하는 동안 로딩 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // 인증된 사용자라면 MainScreen으로 이동
          if (snapshot.hasData) {
            return const MainScreen();
          }
          // 인증되지 않은 사용자라면 SignInScreen으로 이동
          return const SignInScreen();
        },
      ),
    );
  }
}
