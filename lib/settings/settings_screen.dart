import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../const/colors.dart'; // 색상 파일 import

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  // 로그아웃 기능
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).popUntil((route) => route.isFirst); // 첫 화면으로 이동
      print('로그아웃 성공');
    } catch (e) {
      print('로그아웃 실패: $e');
    }
  }

  // 비밀번호 변경
  Future<void> _changePassword() async {
    try {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        throw Exception("새 비밀번호와 확인 비밀번호가 일치하지 않습니다.");
      }

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.updatePassword(_newPasswordController.text);
        print("비밀번호 변경 성공");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("비밀번호가 성공적으로 변경되었습니다.")),
        );

        // 입력 필드 초기화
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        throw Exception("사용자가 로그인되어 있지 않습니다.");
      }
    } catch (e) {
      print("비밀번호 변경 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("비밀번호 변경 실패: $e")),
      );
    }
  }

  // 휴대폰 번호 변경
  Future<void> _changePhoneNumber() async {
    try {
      String newPhoneNumber = _phoneController.text.trim();

      if (newPhoneNumber.isEmpty) {
        throw Exception("휴대폰 번호를 입력해주세요.");
      }

      // 사용자 프로필 업데이트
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePhoneNumber(
          PhoneAuthProvider.credential(
            verificationId: '', // 실제 구현에서는 필요한 값
            smsCode: '', // 실제 구현에서는 필요한 값
          ),
        );
        print("휴대폰 번호 변경 성공");
      }

      // 인증 없이 바로 변경 (데모용으로 실제로는 위의 코드가 필요)
      print("휴대폰 번호 변경 성공: $newPhoneNumber");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("휴대폰 번호가 성공적으로 변경되었습니다.")),
      );

      // 입력 필드 초기화
      _phoneController.clear();
    } catch (e) {
      print("휴대폰 번호 변경 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("휴대폰 번호 변경 실패: $e")),
      );
    }
  }

  // 회원탈퇴
  Future<void> _deleteAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await user.delete(); // Firebase에서 사용자 삭제
        Navigator.of(context).popUntil((route) => route.isFirst); // 첫 화면으로 이동
        print("회원탈퇴 성공");
      } else {
        throw Exception("사용자가 로그인되어 있지 않습니다.");
      }
    } catch (e) {
      print("회원탈퇴 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원탈퇴 실패: $e")),
      );
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          '환경 설정',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: whiteColor),
        ),
        backgroundColor: normalBlueColor, // 헤더 색상
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: mainColor2, // 테두리 내부 배경색
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이메일
                const Text(
                  "이메일",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: moreDeepBlueColor, // 제목 색상
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: deepmainColor, // 필드 배경 색상
                    borderRadius: BorderRadius.circular(20), // 레디우스 100
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText:
                          FirebaseAuth.instance.currentUser?.email ?? "이메일 주소",
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    enabled: false,
                  ),
                ),
                const SizedBox(height: 20),

                // 비밀번호 변경
                Row(
                  children: [
                    const Text(
                      "비밀번호 변경",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: moreDeepBlueColor,
                      ),
                    ),
                    const SizedBox(width: 5), // 타이틀과 버튼 사이의 간격
                    ElevatedButton(
                      onPressed: _changePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: normalBlueColor,
                        minimumSize: const Size(60, 30), // 버튼 크기
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "변경",
                        style: TextStyle(fontSize: 12, color: whiteColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: deepmainColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _currentPasswordController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "현재 비밀번호",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 16),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: deepmainColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _newPasswordController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "새 비밀번호",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 16),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: deepmainColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _confirmPasswordController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "새 비밀번호 확인",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 16),
                    obscureText: true,
                  ),
                ),
                const SizedBox(height: 20),

                // 휴대폰 번호 변경
                Row(
                  children: [
                    const Text(
                      "휴대폰번호 변경",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: moreDeepBlueColor,
                      ),
                    ),
                    const SizedBox(width: 5), // 타이틀과 버튼 사이의 간격
                    ElevatedButton(
                      onPressed: _changePhoneNumber,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: normalBlueColor,
                        minimumSize: const Size(60, 30), // 버튼 크기
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        "변경",
                        style: TextStyle(fontSize: 12, color: whiteColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: deepmainColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "휴대폰 번호",
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: const TextStyle(fontSize: 16),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(height: 30),

                // 로그아웃 버튼
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: normalBlueColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "로그아웃",
                    style: TextStyle(fontSize: 16, color: whiteColor),
                  ),
                ),
                const SizedBox(height: 16),

                // 회원탈퇴 버튼
                ElevatedButton(
                  onPressed: _deleteAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: normalRedColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    "회원탈퇴",
                    style: TextStyle(fontSize: 16, color: whiteColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
