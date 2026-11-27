import 'package:flutter/material.dart';

import 'package:video_call/services/agora_service.dart';
import 'package:video_call/widgets/video_views.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({Key? key}) : super(key: key);   // const 생성자 : 최초 선언 후 변경 불가능한 빌드 타임 함수

  @override
  // State<CamScreen> createState() => _CamScreenState();
  State<CamScreen> createState() {
    return _CamScreenState();
  }
}

class _CamScreenState extends State<CamScreen> {
  late final AgoraService _agoraService;
  late final Future<bool> _initFuture;

  @override
  void initState() {
    super.initState();

    // 서비스 생성 시 상태 변경 콜백으로 setState 전달
    _agoraService = AgoraService(
      onStateChanged: () {
        // 상태 변경 시 setState() 함수 실행
        // 값 변경 시 build() 함수 재실행
        // Clean -> setState() -> Dirty -> build() -> Clean
        if (mounted) setState(() {});
      },
    );

    _initFuture = _agoraService.init();   // build()가 재실행되어도 초기화가 중복되지 않도록 한 번만 실행
  }

  @override
  void dispose() {
    _agoraService.dispose();   // 뒤로가기 등으로 화면 종료 시에도 안전하게 채널 퇴장

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LIVE'),
        actions: [
          // 1. 내 마이크 음소거 및 해제 버튼
          IconButton(
            onPressed: _agoraService.uid != null
              ? () async {
                  await _agoraService.toggleAudio();
                }
              : null,
            icon: Icon(
              _agoraService.isAudioMuted ? Icons.mic_off : Icons.mic,
            ),
            tooltip: _agoraService.isAudioMuted ? 'Unmute Microphone' : 'Mute Microphone',
          ),
          // 내 카메라 끄기 및 켜기 버튼
          IconButton(
            onPressed: _agoraService.uid != null
              ? () async {
                  await _agoraService.toggleVideo();
                }
              : null,
            icon: Icon(
              _agoraService.isVideoMuted ? Icons.videocam_off : Icons.videocam,
            ),
            tooltip: _agoraService.isVideoMuted ? 'Turn Camera On' : 'Turn Camera Off',
          ),
          // 전면 및 후면 카메라 전환 버튼 (엔진이 초기화되어 채널에 입장 후 카메라가 켜져 있을 때만 활성화)
          IconButton(
            onPressed: _agoraService.uid != null
              ? () async {
                  await _agoraService.switchCamera();
                }
              : null,
            icon: const Icon(Icons.cameraswitch),
            tooltip: 'Switch Camera',
          ),
        ],
      ),
      // Future 값을 기반으로 위젯 렌더링
      body: FutureBuilder<bool>(
        future: _initFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // Future 실행 후 에러가 있을 경우 bool 값으로 반환
          // true면 에러, false면 에러가 없는 상태
          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          // Future 실행 후 아직 데이터가 없을 경우 반환받은 데이터가 있는지 확인 (로딩 중)
          // snapshot.data를 실행하면 반환된 데이터값 확인 가능
          if (!snapshot.hasData) {
            return Center(
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDB3FF)),   // 색상 지정
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // 상대방 화면 위젯
                    RemoteVideoView(
                      engine: _agoraService.engine!,
                      otherUid: _agoraService.otherUid,
                      isRemoteVideoMuted: _agoraService.isRemoteVideoMuted,   // 상태 전달
                    ),
                    // 내 화면 위젯 (좌측 상단)
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        color: Colors.grey,
                        height: 160,
                        width: 120,
                        child: LocalVideoView(
                          engine: _agoraService.engine!,
                          uid: _agoraService.uid,
                          isVideoMuted: _agoraService.isVideoMuted,   // 상태 전달
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    await _agoraService.dispose();

                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: Text(
                    'Leave Channel',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }
      ),
    );
  }
}