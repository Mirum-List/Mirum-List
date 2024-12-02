import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ListViewScreen extends StatefulWidget {
  @override
  _ListViewScreenState createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  String selectedButton = 'deadline'; // 현재 선택된 버튼을 저장

// 남은 시간을 계산하는 함수
  String calculateRemainingTime(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return "기한 초과";
    }

    return "${difference.inDays}일 ${difference.inHours % 24}시간 ${difference.inMinutes % 60}분";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButton = 'deadline'; // 선택된 버튼 설정
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedButton == 'deadline'
                      ? Colors.grey
                      : Colors.grey[350],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                child:
                    const Text('마감 기한', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButton = 'importance'; // 선택된 버튼 설정
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedButton == 'importance'
                      ? Colors.grey
                      : Colors.grey[350],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                child: const Text('중요도', style: TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButton = 'recommendation'; // 선택된 버튼 설정
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedButton == 'recommendation'
                      ? Colors.grey
                      : Colors.grey[350],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                ),
                child:
                    const Text('추천 순위', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 10, left: 20, right: 20, bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.grey[200],
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('tasks')
                        .orderBy(
                            selectedButton == 'importance'
                                ? 'importance'
                                : 'deadline',
                            descending: selectedButton == 'importance')
// .orderBy(
// selectedButton == 'importance'
// ? 'deadline'
// : 'importance',
// descending: selectedButton == 'deadline')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final tasks = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: tasks.length,
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          final DateTime deadline =
                              (task['deadline'] as Timestamp).toDate();
                          final String remainingTime =
                              calculateRemainingTime(deadline);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 30),
                            child: Container(
                              width: 330,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Colors.red[200],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(20),
                                        topRight: Radius.circular(20),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
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
                                        SizedBox(width: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: List.generate(
                                            task[
                                                'importance'], // 중요도 값에 따라 동그라미 생성
                                            (index) => const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 2),
                                              child: Icon(
                                                Icons.circle,
                                                size: 10,
                                                color: Colors.white, // 하얀 동그라미
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.check,
                                                  color: Colors.white),
                                              onPressed: () {
// 완료 처리 로직 추가
                                              },
                                              padding:
                                                  EdgeInsets.zero, // 내부 패딩 제거
                                              constraints:
                                                  const BoxConstraints(), // 기본 제약 조건 제거
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.white),
                                              onPressed: () {
// 편집 로직 추가
                                              },
                                              padding:
                                                  EdgeInsets.zero, // 내부 패딩 제거
                                              constraints:
                                                  const BoxConstraints(), // 기본 제약 조건 제거
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.white),
                                              onPressed: () {
                                                FirebaseFirestore.instance
                                                    .collection('tasks')
                                                    .doc(task.id)
                                                    .delete();
                                              },
                                              padding:
                                                  EdgeInsets.zero, // 내부 패딩 제거
                                              constraints:
                                                  const BoxConstraints(), // 기본 제약 조건 제거
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            task['title'], // 할 일 제목
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[300],
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  task['category'], // 카테고리
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                remainingTime, // 남은 시간 표시
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.red[300],
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
}
