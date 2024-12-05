// lib/listView/list_view_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mirum_list/const/colors.dart';
import 'package:mirum_list/listView/modify_list_screen.dart';

class ListViewScreen extends StatefulWidget {
  @override
  _ListViewScreenState createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  String selectedButton = 'deadline'; // 현재 선택된 버튼을 저장

  // 검색바 컨트롤러 + 변수
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 남은 시간을 계산하는 함수
  String calculateRemainingTime(DateTime deadline, DocumentSnapshot task) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      FirebaseFirestore.instance
          .collection('tasks')
          .doc(task.id)
          .update({'completed': true});

      return "기한 초과";
    }

    return "${difference.inDays}일 ${difference.inHours % 24}시간 ${difference.inMinutes % 60}분";
  }

  @override
  void initState() {
    super.initState();
    // 검색 바의 리스너 추가
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    // 컨트롤러 dispose
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          const SizedBox(height: 10),
          // 정렬 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 마감 기한 버튼
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButton = 'deadline'; // 선택된 버튼 설정
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      selectedButton == 'deadline' ? greyColor : ligthGreyColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                child: const Text('마감 기한', style: TextStyle(color: whiteColor)),
              ),
              const SizedBox(width: 10),
              // 중요도 버튼
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButton = 'importance'; // 선택된 버튼 설정
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedButton == 'importance'
                      ? greyColor
                      : ligthGreyColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                child: const Text('중요도', style: TextStyle(color: whiteColor)),
              ),
              const SizedBox(width: 10),
              // 추천 순위 버튼
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButton = 'recommendation'; // 선택된 버튼 설정
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedButton == 'recommendation'
                      ? greyColor
                      : ligthGreyColor,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                child: const Text('추천 순위', style: TextStyle(color: whiteColor)),
              ),
            ],
          ),
          // 검색 바 추가
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: mainColor2,
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _searchController, // 컨트롤러 연결
                decoration: const InputDecoration(
                  hintText: '검색',
                  hintStyle: TextStyle(color: blackColor),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  suffixIcon:
                      Icon(Icons.search, color: blackColor), // 검색 아이콘 추가
                ),
                style: const TextStyle(color: blackColor),
              ),
            ),
          ),
          // 작업 리스트
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: mainColor2,
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .where('completed', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('오류 발생: ${snapshot.error}'),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      // 데이터를 리스트로 변환
                      List<DocumentSnapshot> tasks = snapshot.data!.docs;

                      // 검색어에 따라 필터링된 리스트 생성
                      tasks = tasks.where((doc) {
                        if (_searchQuery.isEmpty) {
                          return true;
                        } else {
                          String title = doc['title'] ?? '';
                          return title.contains(_searchQuery);
                        }
                      }).toList();

                      // 선택된 버튼에 따라 정렬
                      if (selectedButton == 'deadline') {
                        tasks.sort((a, b) {
                          DateTime aDeadline =
                              (a['deadline'] as Timestamp).toDate();
                          DateTime bDeadline =
                              (b['deadline'] as Timestamp).toDate();
                          return aDeadline.compareTo(bDeadline);
                        });
                      } else if (selectedButton == 'importance') {
                        tasks.sort((a, b) {
                          int aImportance = a['importance'] ?? 0;
                          int bImportance = b['importance'] ?? 0;
                          return bImportance.compareTo(aImportance);
                        });
                      } else if (selectedButton == 'recommendation') {
                        tasks.sort((a, b) {
                          DateTime now = DateTime.now();

                          DateTime aDeadline =
                              (a['deadline'] as Timestamp).toDate();
                          int aScore = 0;
                          final aDifference = aDeadline.difference(now).inDays;

                          if (aDifference <= 1) {
                            aScore = 10;
                          } else if (aDifference <= 3) {
                            aScore = 7;
                          } else if (aDifference <= 7) {
                            aScore = 5;
                          } else if (aDifference <= 14) {
                            aScore = 3;
                          } else if (aDifference <= 30) {
                            aScore = 2;
                          } else {
                            aScore = 1;
                          }

                          aScore += a['importance'] as int;

                          DateTime bDeadline =
                              (b['deadline'] as Timestamp).toDate();
                          int bScore = 0;
                          final bDifference = bDeadline.difference(now).inDays;

                          if (bDifference <= 1) {
                            bScore = 10;
                          } else if (bDifference <= 3) {
                            bScore = 7;
                          } else if (bDifference <= 7) {
                            bScore = 5;
                          } else if (bDifference <= 14) {
                            bScore = 3;
                          } else if (bDifference <= 30) {
                            bScore = 2;
                          } else {
                            bScore = 1;
                          }

                          bScore += (b['importance'] ?? 0) as int;

                          // First compare the scores
                          int scoreComparison = bScore.compareTo(aScore);
                          if (scoreComparison != 0) {
                            return scoreComparison;
                          } else {
                            // If scores are equal, compare titles in ascending order
                            String aTitle = a['title'] ?? '';
                            String bTitle = b['title'] ?? '';
                            return aTitle.compareTo(bTitle);
                          }
                        });
                      }

                      return ListView.builder(
                        itemCount: tasks.length,
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final DateTime deadline =
                              (task['deadline'] as Timestamp).toDate();
                          final String remainingTime =
                              calculateRemainingTime(deadline, task);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Container(
                              width: 330,
                              height: 130,
                              decoration: BoxDecoration(
                                color: whiteColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 상단 바
                                  Container(
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: () {
                                        final now = DateTime.now();
                                        final difference =
                                            deadline.difference(now);

                                        if (difference.inDays < 1) {
                                          return lightRed; // 1일 이내 빨간색
                                        } else if (difference.inDays <= 7) {
                                          return lightYellow; // 1주일 이내 노란색
                                        } else {
                                          return lightgreen; // 그 외 초록색
                                        }
                                      }(),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // 마감 기한 날짜 표시
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Text(
                                            DateFormat('yyyy.MM.dd')
                                                .format(deadline),
                                            style: const TextStyle(
                                              color: whiteColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // 중요도 표시
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: List.generate(
                                            task['importance'],
                                            (index) => const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              child: Icon(
                                                Icons.circle,
                                                size: 10,
                                                color: whiteColor, // 하얀 동그라미
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // 액션 아이콘들
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.check,
                                                  color: whiteColor),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('tasks')
                                                    .doc(task.id)
                                                    .update(
                                                        {'completed': true});
                                              },
                                              padding:
                                                  EdgeInsets.zero, // 내부 패딩 제거
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: whiteColor),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ModifyListScreen(
                                                            taskId: task.id,
                                                            taskData: task
                                                                    .data()
                                                                as Map<String,
                                                                    dynamic>),
                                                  ),
                                                );
                                              },
                                              padding:
                                                  EdgeInsets.zero, // 내부 패딩 제거
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: whiteColor),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('tasks')
                                                    .doc(task.id)
                                                    .delete();
                                              },
                                              padding:
                                                  EdgeInsets.zero, // 내부 패딩 제거
                                              constraints:
                                                  const BoxConstraints(),
                                            ),
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
                                          Container(
                                            width: 170,
                                            child: Text(
                                              task['title'], // 할 일 제목
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1, // 한 줄로 제한
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          // 카테고리 및 남은 시간
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              // 카테고리 표시
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: _getCategoryColor(
                                                      task['category']),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  task['category'], // 카테고리
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: whiteColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              // 남은 시간 표시
                                              Container(
                                                width: 130,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: mainColor2,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  remainingTime, // 남은 시간 표시
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: () {
                                                        final now =
                                                            DateTime.now();
                                                        final difference =
                                                            deadline.difference(
                                                                now);

                                                        if (difference.inDays <
                                                            1) {
                                                          return normalRedColor; // 1일 이내 빨간색
                                                        } else {
                                                          return blackColor;
                                                        }
                                                      }()),
                                                ),
                                              ),
                                            ],
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
