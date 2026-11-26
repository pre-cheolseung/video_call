import 'package:flutter/material.dart';

import 'package:video_call/screens/cam_screen.dart';

import 'package:video_call/widgets/entry_button.dart';
import 'package:video_call/widgets/logo.dart';
import 'package:video_call/widgets/logo_image.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);   // const 생성자 : 최초 선언 후 변경 불가능한 빌드 타임 함수

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100]!,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Expanded(child: Logo()),   // 로고
              const Expanded(child: LogoImage()),   // 중앙 이미지
              Expanded(
                child: EntryButton(
                  onTap: () {
                    // 영상 통화 스크린으로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const CamScreen(),
                      ),
                    );
                  },
                ),
              ),   // 화상 통화 시작 버튼
            ],
          ),
        ),
      ),
    );
  }
}