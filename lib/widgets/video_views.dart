import 'package:flutter/material.dart';

import 'package:video_call/consts/agora.dart';

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

// 상대방 화면 (전체 메인 화면)
class RemoteVideoView extends StatelessWidget {
  final RtcEngine engine;
  final int? otherUid;
  final bool isRemoteAudioMuted;   // 상대방 마이크 음소거 상태
  final bool isRemoteVideoMuted;   // 상대방 카메라 꺼짐 상태

  const RemoteVideoView({
    super.key,

    required this.engine,
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
                connection: const RtcConnection(channelId: CHANNEL_NAME),
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

// 드래그하여 네 모서리로 이동 가능한 PIP 컨테이너 위젯
class DraggablePipView extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;   // 탭 이벤트 콜백

  const DraggablePipView({
    super.key,

    required this.child,
    this.onTap,
  });

  @override
  State<DraggablePipView> createState() => _DraggablePipViewState();
}

class _DraggablePipViewState extends State<DraggablePipView> {
  Alignment _alignment = Alignment.topLeft;   // 초기 위치: 좌측 상단
  Offset? _dragOffset;   // 드래그 중일 때의 임시 좌표
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double pipWidth = 120;
        const double pipHeight = 160;
        const double margin = 12;

        // 드래그 중인 경우 손가락 위치를 따라 자유롭게 이동
        if (_isDragging && _dragOffset != null) {
          return Stack(
            children: [
              Positioned(
                left: _dragOffset!.dx.clamp(margin, constraints.maxWidth - pipWidth - margin),
                top: _dragOffset!.dy.clamp(margin, constraints.maxHeight - pipHeight - margin),
                child: _buildDraggableBox(constraints, pipWidth, pipHeight, margin),
              ),
            ],
          );
        }

        // 드래그가 끝난 경우 지정된 모서리로 부드럽게 이동
        return AnimatedAlign(
          alignment: _alignment,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: const EdgeInsets.all(margin),
            child: _buildDraggableBox(constraints, pipWidth, pipHeight, margin),
          ),
        );
      },
    );
  }

  Widget _buildDraggableBox(
    BoxConstraints constraints,
    double pipWidth,
    double pipHeight,
    double margin,
  ) {
    return GestureDetector(
      onTap: widget.onTap,   // 작은 화면을 탭했을 때 화면 전환 실행
      onPanStart: (details) {
        // 현재 Alignment를 기준으로 실제 시작 좌표(x, y) 계산
        final double startX = _alignment.x < 0
          ? margin
          : constraints.maxWidth - pipWidth - margin;
        final double startY = _alignment.y < 0
          ? margin
          : constraints.maxHeight - pipHeight - margin;

        // 상태 변경 시 setState() 함수 실행
        // 값 변경 시 build() 함수 재실행
        // Clean -> setState() -> Dirty -> build() -> Clean
        setState(() {
          _isDragging = true;
          _dragOffset = Offset(startX, startY);
        });
      },
      onPanUpdate: (details) {
        // 상태 변경 시 setState() 함수 실행
        // 값 변경 시 build() 함수 재실행
        // Clean -> setState() -> Dirty -> build() -> Clean
        setState(() {
          _dragOffset = _dragOffset! + details.delta;
        });
      },
      onPanEnd: (details) {
        // 손을 뗀 시점의 PIP 중심 좌표 계산
        final double centerX = _dragOffset!.dx + (pipWidth / 2);
        final double centerY = _dragOffset!.dy + (pipHeight / 2);

        // 화면 절반을 기준으로 가장 가까운 모서리 결정
        final bool isLeft = centerX < constraints.maxWidth / 2;
        final bool isTop = centerY < constraints.maxHeight / 2;

        setState(() {
          _isDragging = false;
          _dragOffset = null;
          if (isTop && isLeft) {
            _alignment = Alignment.topLeft;
          } else if (isTop && !isLeft) {
            _alignment = Alignment.topRight;
          } else if (!isTop && isLeft) {
            _alignment = Alignment.bottomLeft;
          } else {
            _alignment = Alignment.bottomRight;
          }
        });
      },
      child: Container(
        height: pipHeight,
        width: pipWidth,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white70,
            width: 2.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: widget.child,
        ),
      ),
    );
  }
}