import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mirum_list/Log/log_screen.dart';
import 'package:mirum_list/calendar/calendar_screen.dart';
import 'package:mirum_list/const/colors.dart';
import 'package:mirum_list/editList/edit_list_screen.dart';
import 'package:mirum_list/listView/list_view_screen.dart';
import 'package:mirum_list/settings/settings_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 선택된 인덱스 변경
    });
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return  ListViewScreen();
      case 1:
        return const CalendarScreen();
      case 2:
        return const EditListScreen();
      case 3:
        return const LogScreen();
      default:
        return ListViewScreen();
    }
  }

  Widget _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return const Text('리스트 보기');
      case 1:
        return Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Today is  ',
                style: const TextStyle(fontSize: 14.0, color: Colors.black),
              ),
              TextSpan(
                text: DateFormat('yyyy.MM.dd').format(DateTime.now()),
                style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      case 2:
        return const Text('리스트 편집');
      case 3:
        return const Text('로그');
      default:
        return const Text('');
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _getAppBarTitle(),
        backgroundColor: mainColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), 
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: whiteColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '리스트',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '캘린더',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '편집',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: '로그',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: deepBlueColor,
        unselectedItemColor: mainColor,
        onTap: _onItemTapped,
        showSelectedLabels: false, // 선택된 항목의 라벨 숨김
        showUnselectedLabels: false, // 선택되지 않은 항목의 라벨 숨김
      ),
    );
  }
}
