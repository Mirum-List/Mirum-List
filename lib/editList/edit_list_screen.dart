// lib/editList/edit_list_screen.dart

import 'package:flutter/material.dart';
import '../const/colors.dart';
import 'package:intl/intl.dart'; // 날짜 형식 처리를 위한 패키지
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 패키지 추가
import '../model/task.dart'; // Task 모델 임포트

class EditListScreen extends StatefulWidget {
  const EditListScreen({super.key});

  @override
  _EditListScreenState createState() => _EditListScreenState();
}

class _EditListScreenState extends State<EditListScreen> {
  // 컨트롤러
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();

  // 상태 변수
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedImportance = 1;
  String _selectedCategory = '일상';
  List<String> _categories = ['일상', '음악', '운동', '공부'];

  // Firestore 인스턴스
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 컨트롤러 해제
  @override
  void dispose() {
    _titleController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  // 날짜 선택기
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  // 시간 선택기
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  // 중요도 선택 위젯
  Widget _buildImportanceSelector() {
    List<Widget> importanceCircles = [];
    for (int i = 1; i <= 5; i++) {
      importanceCircles.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedImportance = i;
            });
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i <= _selectedImportance ? whiteColor : normalRedColor,
              border: Border.all(color: normalRedColor),
            ),
            child: i <= _selectedImportance
                ? Icon(
                    Icons.check,
                    size: 16,
                    color: normalRedColor,
                  )
                : null,
          ),
        ),
      );
    }
    return Row(
      children: importanceCircles,
    );
  }

  // 카테고리 버튼 위젯 (Wrap 사용)
  Widget _buildCategoryButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 한 버튼의 너비를 계산 (3개 버튼 + 2개의 간격)
        double totalSpacing = 16.0; // Wrap의 spacing * (버튼 수 -1)
        double buttonWidth = (constraints.maxWidth - totalSpacing) / 3;

        return Wrap(
          spacing: 8.0, // 가로 간격
          runSpacing: 8.0, // 세로 간격
          children: [
            for (var category in _categories)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                child: Container(
                  width: buttonWidth,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 패딩 증가
                  decoration: BoxDecoration(
                    color: _selectedCategory == category
                        ? _getCategoryColor(category)
                        : whiteColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _getCategoryColor(category)),
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: TextStyle(
                        color: _selectedCategory == category
                            ? whiteColor
                            : _getCategoryColor(category),
                        fontSize: 16.0, // 폰트 크기 증가
                        fontWeight: _selectedCategory == category
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            // '+' 버튼
            GestureDetector(
              onTap: () {
                _showAddCategoryDialog();
              },
              child: Container(
                width: buttonWidth,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12), // 패딩 증가
                decoration: BoxDecoration(
                  color: whiteColor,
                  border: Border.all(color: mainColor),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Text(
                    '+',
                    style: TextStyle(
                      color: mainColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 카테고리 색상 매핑 헬퍼 함수
  Color _getCategoryColor(String category) {
    switch (category) {
      case '운동':
        return lightpurple;
      case '공부':
        return lightorange;
      case '음악':
        return normalBlueColor;
      case '일상':
        return moreDeepBlueColor;
      default:
        return lightBlueColor;
    }
  }

  // 할 일 추가 함수
  Future<void> _addTask() async {
    String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    // 현재 사용자 가져오기 (옵션: 사용자 인증을 사용하는 경우)
    // User? user = FirebaseAuth.instance.currentUser;
    // if (user == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('사용자가 인증되지 않았습니다.')),
    //   );
    //   return;
    // }

    // 마감기한과 시간을 합쳐서 하나의 DateTime 객체 생성
    DateTime deadlineDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // 할 일 데이터
    Map<String, dynamic> taskData = {
      'title': title,
      'deadline': Timestamp.fromDate(deadlineDateTime),
      'importance': _selectedImportance,
      'category': _selectedCategory,
      'completed': false, // 완료 여부 기본 값 false 설정
      'createdAt': FieldValue.serverTimestamp(), // 생성 시간
      // 'userId': user?.uid, // 사용자 인증을 사용하는 경우 추가
    };

    try {
      await _firestore.collection('tasks').add(taskData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('할 일이 추가되었습니다!')),
      );

      // 필드 초기화
      _titleController.clear();
      setState(() {
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
        _selectedImportance = 1;
        _selectedCategory = _categories.isNotEmpty ? _categories[0] : '';
      });
    } catch (e) {
      print('Error adding task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('할 일 추가에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  // 카테고리 추가 다이얼로그
  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('카테고리 추가'),
          content: TextField(
            controller: _customCategoryController,
            decoration: InputDecoration(
              hintText: '새 카테고리를 입력하세요',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _customCategoryController.clear();
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                String newCategory = _customCategoryController.text.trim();
                if (newCategory.isNotEmpty && !_categories.contains(newCategory)) {
                  setState(() {
                    _categories.add(newCategory);
                    _selectedCategory = newCategory;
                  });
                }
                _customCategoryController.clear();
                Navigator.of(context).pop();
              },
              child: Text('추가'),
            ),
          ],
        );
      },
    );
  }

  // 빌드 메소드
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 제목 입력 필드
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '제목',
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16.0),
            // 마감기한, 중요도, 카테고리 박스
            Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 마감기한
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '마감기한',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          // 날짜 선택
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 16.0, color: mainColor),
                                  SizedBox(width: 4.0),
                                  Text(
                                    DateFormat('yyyy-MM-dd').format(_selectedDate),
                                    style: TextStyle(
                                      color: mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          // 시간 선택
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding:
                                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 16.0, color: mainColor),
                                  SizedBox(width: 4.0),
                                  Text(
                                    _selectedTime.format(context),
                                    style: TextStyle(
                                      color: mainColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  // 중요도
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '중요도',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildImportanceSelector(),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  // 카테고리
                  Text(
                    '카테고리',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  _buildCategoryButtons(),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            // 추가하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addTask, // Firestore에 데이터 저장 함수 호출
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  '추가하기',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: whiteColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}