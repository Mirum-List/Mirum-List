import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:mirum_list/const/colors.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // 현재 날짜
  DateTime _focusedDay = DateTime.now();

  // 선택된 날짜
  DateTime? _selectedDay;

  // 날짜별 할 일 목록
  final Map<DateTime, List<Map<String, dynamic>>> _mockEvents = {
    DateTime.utc(2024, 12, 1): [
      {'title': '기타 oo곡 연습', 'category': '음악', 'priority': 3},
    ],
    DateTime.utc(2024, 12, 2): [
      {'title': '프로젝트 작업', 'category': '공부', 'priority': 5},
    ],
    DateTime.utc(2024, 12, 3): [
      {'title': '운동복 사기', 'category': '운동', 'priority': 2},
    ],
  };

  // 카테고리별 색 설정
  final Map<String, Color> _categoryColors = {
    '음악': Colors.blue,
    '공부': Colors.orange,
    '운동': Colors.green,
    '일상': Colors.purple,
  };

  // 특정 날짜에 해당하는 할 일 목록 불러오기
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _mockEvents[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    // 선택된 날짜 할 일 목록
    final selectedEvents = _getEventsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      body: Container(
        color: Colors.grey[200],
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // 캘린더
                TableCalendar(
                  firstDay: DateTime.utc(1900, 1, 1),
                  lastDay: DateTime.utc(2040, 12, 31),
                  focusedDay: _focusedDay, // 현재 포커스된 날짜
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day), // 선택된 날짜 확인
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay; // 선택된 날짜
                      _focusedDay = focusedDay;
                    });
                  },
                  eventLoader: _getEventsForDay, // 선택된 날짜의 할 일 목록
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: deepBlueColor, // 오늘 날짜 표시
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: moreDeepBlueColor, // 선택된 날짜 표시
                      shape: BoxShape.circle,
                    ),
                  ),

                  // 날짜별 할 일 갯수 표시
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final dayEvents = _getEventsForDay(date); // 해당 날짜의 할 일 목록

                      if (dayEvents.isEmpty) return null;

                      return Column(
                        children: [
                          const SizedBox(height: 32),
                          // 날짜별로 할 일이 3개 이하일 경우, 최대 3개까지 표시
                          for (var i = 0;
                          i < (dayEvents.length > 3 ? 3 : dayEvents.length);
                          i++)
                            Container(
                              width: 50,
                              height: 4,
                              margin: const EdgeInsets.symmetric(vertical: 2.0),
                              decoration: BoxDecoration(
                                color: _categoryColors[dayEvents[i]['category']] ??
                                    Colors.grey, // 카테고리별 색상
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          // 할 일이 3개 이상일 경우 남은 할 일 갯수 표시
                          if (dayEvents.length > 3)
                            Text(
                              '+${dayEvents.length - 3}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
                const Divider(),
                // 선택한 날짜 할 일 목록 보여줌
                if (_selectedDay != null)
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedEvents.length,
                      itemBuilder: (context, index) {
                        final event = selectedEvents[index]; // 할 일
                        final categoryColor =
                            _categoryColors[event['category']] ?? Colors.grey; // 카테고리 색상

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.2), // 카테고리 색상을 적용한 배경
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: [
                              // 카테고리
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white, // 카테고리 배경
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  event['category'], // 카테고리 이름 표시
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8.0),
                              // 할 일 제목
                              Expanded(
                                child: Text(
                                  event['title'], // 할 일 제목 표시
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ),
                              // 중요도 표시
                              Row(
                                children: List.generate(event['priority'], (dotIndex) {
                                  return Icon(
                                    Icons.circle,
                                    size: 13,
                                    color: Colors.white,
                                  );
                                }),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
