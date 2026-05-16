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
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.125, // 45 degrees (turns + into x)
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
    Future.delayed(const Duration(milliseconds: 250), () {
      action?.call();
    });
    HapticFeedback.mediumImpact();
  }

  // Helper widget to build perfectly aligned small FABs
  Widget _buildSmallFab({
    required String heroTag,
    required String iconName,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      // Centers the 40px small FAB perfectly over the 56px main FAB
      padding: const EdgeInsets.only(right: 8.0),
      child: FloatingActionButton.small(
        heroTag: heroTag,
        onPressed: onTap,
        backgroundColor: color,
        elevation: 4,
        child: CustomIconWidget(
          iconName: iconName,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // FIX: Replaced SizeTransition with AnimatedSize pinned to the bottom right
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.bottomRight,
          child: _isExpanded
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSmallFab(
                      heroTag: "voice_fab",
                      iconName: 'mic',
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      onTap: () => _onActionTap(widget.onVoiceInput),
                    ),
                    const SizedBox(height: 16),
                    _buildSmallFab(
                      heroTag: "add_fab",
                      iconName: 'add',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      onTap: () => _onActionTap(widget.onAddTask),
                    ),
                    const SizedBox(height: 16),
                  ],
                )
              : const SizedBox.shrink(), // Takes up 0 space when hidden
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
      ],
    );
  }
}