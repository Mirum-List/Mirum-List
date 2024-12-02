import 'package:flutter/material.dart';

class ListViewScreen extends StatefulWidget {
  @override
  _ListViewScreenState createState() => _ListViewScreenState();
}

class _ListViewScreenState extends State<ListViewScreen> {
  String selectedButton = 'deadline'; // 현재 선택된 버튼을 저장

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
                  child: ListView.builder(
                    itemCount: 10, // 10개의 항목 생성
                    padding: const EdgeInsets.all(20),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Container(
                          width: 330, // 컨테이너 너비
                          height: 100, // 컨테이너 높이
                          decoration: BoxDecoration(
                            color: Colors.white, // 하단 흰색 배경
                            borderRadius:
                                BorderRadius.circular(20), // 전체 둥근 모서리
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                height: 35, // 상단 빨간 영역 높이
                                decoration: BoxDecoration(
                                  color: Colors.red[200], // 상단 배경색
                                  borderRadius: const BorderRadius.only(
                                      topLeft:
                                          Radius.circular(8), // 왼쪽 상단 둥근 모서리
                                      topRight:
                                          Radius.circular(8)), // 오른쪽 상단 둥근 모서리
                                ),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft:
                                        Radius.circular(20), // 왼쪽 하단 둥근 모서리
                                    bottomRight:
                                        Radius.circular(20), // 오른쪽 하단 둥근 모서리
                                  ),
                                  child: Container(
                                    color: Colors.white, // 하단 흰색 영역
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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
