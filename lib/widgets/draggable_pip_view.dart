import 'package:flutter/material.dart';

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
  Alignment _alignment = Alignment.topLeft;   // 초기 위치 : 좌측 상단
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
          // 내부 네이티브 영상 뷰가 탭 및 드래그 터치를 가로채지 않도록 처리
          child: AbsorbPointer(
            child: widget.child,
          ),
        ),
      ),
    );
  }
}