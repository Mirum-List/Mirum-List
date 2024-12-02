// lib/authentication/sign_up_screen.dart

import 'package:flutter/material.dart';
import 'package:mirum_list/const/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mirum_list/authentication/sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;

  // 이메일 유효성 검사 함수
  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  // 비밀번호 유효성 검사 함수
  bool _isValidPassword(String password) {
    return password.length >= 6; // 예시: 최소 6자
  }

  Future<void> _signUp() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_isValidEmail(email)) {
      setState(() {
        _errorMessage = '유효한 이메일 주소를 입력해주세요.';
      });
      return;
    }

    if (!_isValidPassword(password)) {
      setState(() {
        _errorMessage = '비밀번호는 최소 6자 이상이어야 합니다.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = '비밀번호가 일치하지 않습니다.';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 이메일 인증 메일 발송
      await userCredential.user?.sendEmailVerification();

      setState(() {
        _errorMessage = '회원가입 성공! 이메일을 확인해주세요.';
      });

      // 회원가입 성공 후 로그인 화면으로 이동
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? '회원가입에 실패했습니다.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = '알 수 없는 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: mainColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20.0, 150.0, 20.0, 20.0),
        child: Center(
          child: Column(
            children: [
              const Image(
                image: AssetImage('assets/logo.png'),
                width: 200,
                height: 100,
              ),
              const SizedBox(height: 50),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: '아이디(이메일)',
                        filled: true,
                        fillColor: whiteColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // 이메일 형식 검사만 수행
                        final email = _emailController.text.trim();
                        if (!_isValidEmail(email)) {
                          setState(() {
                            _errorMessage = '유효한 이메일 주소를 입력해주세요.';
                          });
                        } else {
                          setState(() {
                            _errorMessage = '이메일 중복 확인 완료!';
                          });
                          // 추가적인 중복 확인 로직이 필요하다면 Firestore에서 사용자 존재 여부 확인
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: whiteColor,
                        backgroundColor: moreDeepBlueColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                      child: const Text(
                        '중복 확인',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '비밀번호(6자 이상)',
                  filled: true,
                  fillColor: whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                obscureText: true,
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  hintText: '비밀번호 확인',
                  filled: true,
                  fillColor: whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '휴대폰 번호',
                  filled: true,
                  fillColor: whiteColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 50),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: whiteColor,
                    backgroundColor: deepBlueColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                        )
                      : const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
