import 'package:flutter/material.dart';

import 'package:video_call/consts/agora.dart';
import 'package:video_call/screens/cam_screen.dart';
import 'package:video_call/widgets/entry_button.dart';
import 'package:video_call/widgets/logo.dart';
import 'package:video_call/widgets/logo_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);   // const 생성자 : 최초 선언 후 변경 불가능한 빌드 타임 함수

  @override
  // State<HomeScreen> createState() => _HomeScreenState();
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}


class _HomeScreenState extends State<HomeScreen> {
  String _selectedChannel = CHANNEL_TOKENS.keys.first;   // 기본 선택 방: CHANNEL_TOKENS의 첫 번째 키 ('Room1')

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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // 방 선택 드롭다운 메뉴
                    DropdownButtonFormField<String>(
                      initialValue: _selectedChannel,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.meeting_room),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      items: CHANNEL_TOKENS.keys.map((String roomName) {
                        return DropdownMenuItem<String>(
                          value: roomName,
                          child: Text(roomName),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedChannel = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // 입장 버튼
                    EntryButton(
                      onTap: () {
                        // 입력한 방 이름을 CamScreen으로 전달하며 영상 통화 스크린으로 이동
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CamScreen(channelName: _selectedChannel),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),   // 화상 통화 시작 버튼
            ],
          ),
        ),
      ),
    );
  }
}