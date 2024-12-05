// lib/Log/log_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mirum_list/const/colors.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  @override
  Widget build(BuildContext context) {
    // Firestore 쿼리 설정
    Query tasksQuery = FirebaseFirestore.instance.collection('tasks');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 작업 리스트
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.grey[200],
                  child: StreamBuilder<QuerySnapshot>(
                    stream: tasksQuery.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('오류 발생: ${snapshot.error}'),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // 모든 작업을 가져옴
                      final allTasks = snapshot.data!.docs;

                      // 완료된 작업 또는 마감 기한이 지나고 미완료된 작업 필터링
                      final tasks = allTasks.where((task) {
                        final DateTime deadline =
                            (task['deadline'] as Timestamp).toDate();
                        final bool completed = task['completed'] ?? false;
                        final now = DateTime.now();
                        if (completed) {
                          return true; // 완료된 작업 포함
                        } else if (deadline.isBefore(now) && !completed) {
                          return true; // 마감 기한이 지났지만 미완료된 작업 포함
                        } else {
                          return false; // 그 외의 작업 제외
                        }
                      }).toList();

                      if (tasks.isEmpty) {
                        return Center(
                          child: Text('작업이 없습니다.'),
                        );
                      }

                      // 생성일 역순으로 정렬하여 최신 작업이 위로 오도록 설정
                      tasks.sort((a, b) {
                        Timestamp aTimestamp = a['createdAt'] as Timestamp;
                        Timestamp bTimestamp = b['createdAt'] as Timestamp;
                        return bTimestamp.compareTo(aTimestamp);
                      });

                      return ListView.builder(
                        // 위에서부터 배치되도록 함
                        itemCount: tasks.length,
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final DateTime deadline =
                              (task['deadline'] as Timestamp).toDate();
                          final bool completed = task['completed'] ?? false;
                          final Color topBarColor =
                              completed ? Colors.grey : Colors.red[200]!;
                          final String statusText = completed ? '완료' : '미완료';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Container(
                              width: 330,
                              height: 130,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 상단 바
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: topBarColor,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 날짜 표시
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            DateFormat('yyyy.MM.dd')
                                                .format(deadline),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // 중요도 표시 (흰색 점) - 카테고리 박스 밖 왼쪽에 위치
                                        Row(
                                          children: [
                                            Row(
                                              children: List.generate(
                                                task[
                                                    'importance'], // 중요도 값에 따라 동그라미 생성
                                                (idx) => const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 2),
                                                  child: Icon(
                                                    Icons.circle,
                                                    size: 8,
                                                    color:
                                                        Colors.white, // 하얀 동그라미
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            // 카테고리 표시 - 오른쪽 끝에 위치
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 5),
                                              decoration: BoxDecoration(
                                                color: _getCategoryColor(
                                                    task['category']),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Text(
                                                task['category'], // 카테고리
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // 할 일 내용
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // 할 일 제목
                                          Expanded(
                                            child: Text(
                                              task['title'], // 할 일 제목
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                decoration: completed
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                              ),
                                              maxLines: 1, // 한 줄로 제한
                                              overflow: TextOverflow
                                                  .ellipsis, // 글자 수 제한
                                            ),
                                          ),
                                          // 완료 상태 표시 - 크기 증가
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              statusText,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: completed
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 카테고리 색상 매핑 함수
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
}
