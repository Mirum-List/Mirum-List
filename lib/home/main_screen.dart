import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mirum_list/Log/log_screen.dart';
import 'package:mirum_list/calendar/calendar_screen.dart';
import 'package:mirum_list/const/colors.dart';
import 'package:mirum_list/editList/edit_list_screen.dart';
import 'package:mirum_list/listView/list_view_screen.dart';

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
        return ListViewScreen();
      case 1:
        return CalendarScreen();
      case 2:
        return EditListScreen();

      case 3:
        return LogScreen();

      default:
        return ListViewScreen();
    }
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return '리스트 보기';
      case 1:
        return DateFormat('yyyy.MM.dd').format(DateTime.now());
      case 2:
        return '리스트 편집';
      case 3:
        return '로그';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mainColor,
        title: Padding(
          padding: const EdgeInsets.only(top: 10.0), // 텍스트를 아래로 내림
          child: Text(
            _getAppBarTitle(),
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: whiteColor),
          ),
        ),
      ),
      body: _getCurrentPage(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: whiteColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '첫 번째',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '두 번째',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: '세 번째',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            label: "네 번째",
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: deepBlueColor,
        unselectedItemColor: mainColor,
        // 선택되지 않았을 때 색상
        onTap: _onItemTapped,
        showSelectedLabels: false, // 선택된 항목의 라벨 숨김
        showUnselectedLabels: false, // 선택되지 않은 항목의 라벨 숨김
      ),
    );
  }
}
