import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// 내 화면 (좌측 상단 작은 화면)
class LocalVideoView extends StatelessWidget {
  final RtcEngine engine;
  final int? uid;
  final bool isAudioMuted;   // 내 마이크 음소거 상태
  final bool isVideoMuted;   // 내 카메라 꺼짐 상태

  const LocalVideoView({
    super.key,

    required this.engine,
    required this.uid,
    required this.isAudioMuted,
    required this.isVideoMuted,
  });

  @override
  Widget build(BuildContext context) {
    if (uid != null) {
      return Stack(
        children: [
          // 내 카메라가 꺼져 있을 때 안내 화면 표시
          if (isVideoMuted)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Icon(
                  Icons.videocam_off,
                  color: Colors.white70,
                  size: 32,
                ),
              ),
            )
          // 내 카메라가 켜져 있을 때 정상 송출 (동영상을 화면에 보여주는 위젯)
          else
            AgoraVideoView(
              // 내 동영상 정보를 AgoraVideoView 위젯을 통해 보여주는 것이 가능
              controller: VideoViewController(
                rtcEngine: engine,
                canvas: const VideoCanvas(uid: 0),   // 내 영상을 보여주기 위해 0 입력
              ),
            ),

          // 내가 음소거 중일 때 우측 하단에 작은 원형 배지 표시
          if (isAudioMuted)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mic_off,
                  color: Colors.redAccent,
                  size: 16,
                ),
              ),
            ),
        ],
      );
    }

    // 내가 아직 채널에 접속하지 않았다면 로딩 화면
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCDB3FF)),   // 색상 지정
      ),
    );
  }
}