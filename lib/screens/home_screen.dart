import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);   // const 생성자 : 최초 선언 후 변경 불가능한 빌드 타임 함수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(child: Logo()),   // 로고
              Expanded(child: Image()),   // 중앙 이미지
              Expanded(child: EntryButton()),   // 화상 통화 시작 버튼
            ],
          ),
        ),
      ),
    );
  }
}