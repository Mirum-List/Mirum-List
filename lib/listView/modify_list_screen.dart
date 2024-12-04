import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../const/colors.dart';

class ModifyListScreen extends StatefulWidget {
  final String taskId; // 수정할 Task의 ID
  final Map<String, dynamic> taskData; // Task의 데이터

  const ModifyListScreen(
      {super.key, required this.taskId, required this.taskData});

  @override
  _ModifyListScreenState createState() => _ModifyListScreenState();
}

class _ModifyListScreenState extends State<ModifyListScreen> {
  late TextEditingController _titleController;
  late TextEditingController _customCategoryController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late int _selectedImportance;
  late String _selectedCategory;
  late List<String> _categories;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.taskData['title']);
    _customCategoryController = TextEditingController();
    _selectedDate = (widget.taskData['deadline'] as Timestamp).toDate();
    _selectedTime = TimeOfDay.fromDateTime(_selectedDate);
    _selectedImportance = widget.taskData['importance'];
    _selectedCategory = widget.taskData['category'];
    _categories = ['일상', '음악', '운동', '공부'];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _updateTask() async {
    String title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('제목을 입력해주세요.')),
      );
      return;
    }

    DateTime deadlineDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    Map<String, dynamic> updatedTaskData = {
      'title': title,
      'deadline': Timestamp.fromDate(deadlineDateTime),
      'importance': _selectedImportance,
      'category': _selectedCategory,
      'completed': widget.taskData['completed'], // 기존 완료 상태 유지
    };

    try {
      print('11111');
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.taskId)
          .update(updatedTaskData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정이 완료되었습니다!')),
      );
      print('2222');

      Navigator.pop(context); // 이전 화면으로 돌아가기
    } catch (e) {
      print('Error updating task: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('수정에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildImportanceSelector() {
    return Row(
      children: List.generate(5, (index) {
        int level = index + 1;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedImportance = level;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: level <= _selectedImportance ? whiteColor : normalRedColor,
              border: Border.all(color: normalRedColor),
            ),
            child: level <= _selectedImportance
                ? const Icon(Icons.check, size: 16, color: normalRedColor)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildCategoryButtons() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        for (var category in _categories)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: _selectedCategory == category
                    ? _getCategoryColor(category)
                    : whiteColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getCategoryColor(category)),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: _selectedCategory == category
                      ? whiteColor
                      : _getCategoryColor(category),
                  fontSize: 14,
                ),
              ),
            ),
          ),
        GestureDetector(
          onTap: _showAddCategoryDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: whiteColor,
              border: Border.all(color: mainColor),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.add, color: mainColor),
          ),
        ),
      ],
    );
  }

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

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('카테고리 추가'),
          content: TextField(
            controller: _customCategoryController,
            decoration: const InputDecoration(hintText: '새 카테고리를 입력하세요'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _customCategoryController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                String newCategory = _customCategoryController.text.trim();
                if (newCategory.isNotEmpty &&
                    !_categories.contains(newCategory)) {
                  setState(() {
                    _categories.add(newCategory);
                    _selectedCategory = newCategory;
                  });
                }
                _customCategoryController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('추가'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text(
            '리스트 수정',
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 24, color: whiteColor),
          ),
          backgroundColor: mainColor),
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: mainColor2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: '제목',
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('마감기한',
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickDate,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16.0, color: mainColor),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    DateFormat('yyyy-MM-dd')
                                        .format(_selectedDate),
                                    style: const TextStyle(color: mainColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16.0, color: mainColor),
                                  const SizedBox(width: 4.0),
                                  Text(
                                    _selectedTime.format(context),
                                    style: const TextStyle(color: mainColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('중요도',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          )),
                      _buildImportanceSelector(),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  const Text('카테고리',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 8.0),
                  _buildCategoryButtons(),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateTask,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  '수정하기',
                  style: TextStyle(fontSize: 16.0, color: whiteColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
