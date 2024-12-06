import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  // Firestore에서 가져온 할 일 목록
  Map<DateTime, List<Map<String, dynamic>>> _events = {};

  // 카테고리 색상 정의
  Color _getCategoryColor(String category) {
    switch (category) {
      case '운동':
        return ligthGreyColor;
      case '공부':
        return lightorange;
      case '음악':
        return pinkColor;
      case '일상':
        return brownColor;
      default:
        return beigeColor;
    }
  }

  // Firestore 데이터 로드
  void _loadEventsFromFirestore() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('tasks')
        .get(); // Firestore의 'tasks' 컬렉션에서 데이터를 가져옴

    Map<DateTime, List<Map<String, dynamic>>> loadedEvents = {};

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final deadline = (data['deadline'] as Timestamp).toDate();

      // 날짜별로 할 일 분류
      final eventDate =
      DateTime.utc(deadline.year, deadline.month, deadline.day);

      if (!loadedEvents.containsKey(eventDate)) {
        loadedEvents[eventDate] = [];
      }

      loadedEvents[eventDate]?.add({
        'id': doc.id,
        'title': data['title'],
        'category': data['category'],
        'priority': data['importance'],
      });
    }

    setState(() {
      _events = loadedEvents; // 가져온 데이터를 상태로 저장
    });
  }

  // 특정 날짜에 해당하는 할 일 목록 불러오기
  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _loadEventsFromFirestore(); // Firestore 데이터 로드
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
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Column(
              children: [
                // 캘린더
                TableCalendar(
                  firstDay: DateTime.utc(1900, 1, 1),
                  lastDay: DateTime.utc(2040, 12, 31),
                  focusedDay: _focusedDay, // 현재 포커스된 날짜
                  selectedDayPredicate: (day) =>
                      isSameDay(_selectedDay, day), // 선택된 날짜 확인
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
                    cellMargin: EdgeInsets.all(15),
                  ),
                  // 날짜별 할 일 갯수 표시
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      final dayEvents = _getEventsForDay(date); // 해당 날짜의 할 일 목록

                      if (dayEvents.isEmpty) return null;

                      return Column(
                        children: [
                          const SizedBox(height: 37),
                          for (var i = 0;
                          i < (dayEvents.length > 2 ? 2 : dayEvents.length);
                          i++)
                            Container(
                              width: 30,
                              height: 1.5,
                              margin: const EdgeInsets.symmetric(vertical: 0.5),
                              decoration: BoxDecoration(
                                color:
                                _getCategoryColor(dayEvents[i]['category']), // 카테고리별 색상
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          if (dayEvents.length > 2)
                            Text(
                              '+${dayEvents.length - 2}',
                              style: const TextStyle(
                                fontSize: 7,
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
                        _getCategoryColor(event['category']); // 카테고리 색상

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: categoryColor
                                .withOpacity(0.2), // 카테고리 색상을 적용한 배경
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            children: [
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
                              Expanded(
                                child: Text(
                                  event['title'], // 할 일 제목 표시
                                  style: const TextStyle(fontSize: 16.0),
                                ),
                              ),
                              Row(
                                children: List.generate(event['priority'],
                                        (dotIndex) {
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
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
