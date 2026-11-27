import 'package:flutter/material.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

// 상대방 화면 (전체 메인 화면)
class RemoteVideoView extends StatelessWidget {
  final RtcEngine engine;
  final String channelName;   // 방 이름
  final int? otherUid;
  final bool isRemoteAudioMuted;   // 상대방 마이크 음소거 상태
  final bool isRemoteVideoMuted;   // 상대방 카메라 꺼짐 상태

  const RemoteVideoView({
    super.key,

    required this.engine,
    required this.channelName,
    required this.otherUid,
    required this.isRemoteAudioMuted,
    required this.isRemoteVideoMuted,
  });

  @override
  Widget build(BuildContext context) {
    if (otherUid != null) {
      return Stack(
        children: [
          // 상대방이 카메라를 껐을 때 안내 화면 표시
          if (isRemoteVideoMuted)
            Container(
              color: Colors.black87,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.videocam_off,
                      color: Colors.white70,
                      size: 48,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'The other user turned off their camera.',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          // 상대방 카메라가 켜져 있을 때 정상 송출 (동영상을 화면에 보여주는 위젯)
          else
            AgoraVideoView(
              // 상대방 동영상 정보를 AgoraVideoView 위젯을 통해 보여주는 것이 가능
              controller: VideoViewController.remote(
                rtcEngine: engine,
                canvas: VideoCanvas(uid: otherUid),   // 상대방 영상을 보여주기 위해 otherUid 입력
                connection: RtcConnection(channelId: channelName),   // 전달받은 channelName 적용
              ),
            ),

          // 상대방이 음소거했을 때 좌측 하단에 배지 표시
          if (isRemoteAudioMuted)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mic_off,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Muted',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // 상대가 아직 채널에 접속하지 않았다면 대기 메시지
    return const Center(
      child: Text(
        'Please wait until another user joins.',
        textAlign: TextAlign.center,
      ),
    );
  }
}