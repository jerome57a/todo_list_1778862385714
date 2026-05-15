import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';

class QuickAddFabWidget extends StatefulWidget {
  final VoidCallback? onAddTask;
  final VoidCallback? onVoiceInput;

  const QuickAddFabWidget({
    super.key,
    this.onAddTask,
    this.onVoiceInput,
  });

  @override
  State<QuickAddFabWidget> createState() => _QuickAddFabWidgetState();
}

class _QuickAddFabWidgetState extends State<QuickAddFabWidget>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.125, // 45 degrees
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    HapticFeedback.lightImpact();
  }

  void _onActionTap(VoidCallback? action) {
    _toggleExpanded();
    Future.delayed(const Duration(milliseconds: 150), () {
      action?.call();
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Voice Input FAB
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -70 * _expandAnimation.value),
              child: Transform.scale(
                scale: _expandAnimation.value,
                child: Opacity(
                  opacity: _expandAnimation.value,
                  child: FloatingActionButton(
                    heroTag: "voice_fab",
                    onPressed: () => _onActionTap(widget.onVoiceInput),
                    backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                    child: CustomIconWidget(
                      iconName: 'mic',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Quick Add FAB
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -140 * _expandAnimation.value),
              child: Transform.scale(
                scale: _expandAnimation.value,
                child: Opacity(
                  opacity: _expandAnimation.value,
                  child: FloatingActionButton(
                    heroTag: "add_fab",
                    onPressed: () => _onActionTap(widget.onAddTask),
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    child: CustomIconWidget(
                      iconName: 'add',
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // Main FAB
        FloatingActionButton(
          heroTag: "main_fab",
          onPressed: _toggleExpanded,
          backgroundColor: _isExpanded
              ? AppTheme.lightTheme.colorScheme.surface
              : AppTheme.lightTheme.colorScheme.primary,
          elevation: _isExpanded ? 2 : 6,
          child: AnimatedBuilder(
            animation: _rotateAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * 2 * 3.14159,
                child: CustomIconWidget(
                  iconName: _isExpanded ? 'close' : 'add',
                  color: _isExpanded
                      ? AppTheme.lightTheme.colorScheme.onSurface
                      : Colors.white,
                  size: 28,
                ),
              );
            },
          ),
        ),

        // Backdrop
        _isExpanded
            ? Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleExpanded,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
