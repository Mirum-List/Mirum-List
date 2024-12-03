// lib/Log/log_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지 임포트
import '../model/task.dart'; // Task 모델 임포트
import '../const/colors.dart'; // 색상 상수 임포트
import 'package:intl/intl.dart'; // 날짜 형식 처리를 위한 패키지

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  List<Task> _tasks = []; // Firestore에서 불러온 할 일 목록
  bool _isLoading = false; // 로딩 상태
  String? _errorMessage; // 에러 메시지

  // Firestore에서 할 일 데이터 가져오기
  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Firestore 'tasks' 컬렉션에서 데이터 가져오기
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('tasks')
          .orderBy('createdAt', descending: true) // 생성일 기준 내림차순 정렬
          .get();

      // Task 모델로 변환
      List<Task> tasks =
          snapshot.docs.map((doc) => Task.fromDocument(doc)).toList();

      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '할 일 데이터를 불러오는 데 실패했습니다.';
      });
      print('Error fetching tasks: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 할 일 목록을 표시하는 위젯
  Widget _buildTaskList() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }

    if (_tasks.isEmpty) {
      return Center(child: Text('저장된 할 일이 없습니다.'));
    }

    return ListView.builder(
      itemCount: _tasks.length,
      itemBuilder: (context, index) {
        Task task = _tasks[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getImportanceColor(task.importance),
              child: Text(
                task.importance.toString(),
                style: TextStyle(color: whiteColor),
              ),
            ),
            title: Text(task.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '마감기한: ${DateFormat('yyyy-MM-dd – kk:mm').format(task.deadline)}'),
                Text('카테고리: ${task.category}'),
              ],
            ),
          ),
        );
      },
    );
  }

  // 중요도에 따른 색상 반환 <- 원래는 동그라미 개수인데 일단 색상으로 표시해놨음
  Color _getImportanceColor(int importance) {
    switch (importance) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.yellow;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 할 일 불러오기 버튼
            ElevatedButton(
              onPressed: _fetchTasks, // 버튼 클릭 시 데이터 불러오기
              child: Text('할 일 불러오기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor, // 버튼 배경색
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              ),
            ),
            SizedBox(height: 16.0),
            // 할 일 목록 표시
            Expanded(
              child: _buildTaskList(),
            ),
          ],
        ),
      ),
    );
  }
}
