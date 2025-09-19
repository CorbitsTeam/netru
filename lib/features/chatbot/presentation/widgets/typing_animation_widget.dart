import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Simple and reliable typing animation widget
class TypingAnimationWidget extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final Duration? typingSpeed;
  final VoidCallback? onComplete;
  final bool autoStart;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final Color? cursorColor;
  final bool showCursor;

  const TypingAnimationWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.typingSpeed,
    this.onComplete,
    this.autoStart = true,
    this.textDirection = TextDirection.rtl,
    this.textAlign = TextAlign.right,
    this.cursorColor,
    this.showCursor = true,
  });

  @override
  State<TypingAnimationWidget> createState() => _TypingAnimationWidgetState();
}

class _TypingAnimationWidgetState extends State<TypingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;

  String _displayedText = '';
  bool _isCompleted = false;
  List<String> _characters = [];

  Duration get _typingSpeed =>
      widget.typingSpeed ?? const Duration(milliseconds: 15);

  @override
  void initState() {
    super.initState();

    // Initialize cursor blinking animation
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _cursorAnimation = CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    );

    if (widget.autoStart) {
      _startTyping();
    }
  }

  @override
  void didUpdateWidget(TypingAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text && widget.text.isNotEmpty) {
      // Reset and start typing the new text
      _displayedText = '';
      _isCompleted = false;
      _characters = [];
      if (widget.autoStart) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startTyping();
        });
      }
    }
  }

  void _startTyping() async {
    _displayedText = '';
    _isCompleted = false;

    // Sanitize text to prevent UTF-16 issues
    final sanitizedText = _sanitizeText(widget.text);

    // Convert to list of characters for proper iteration
    _characters = sanitizedText.split('');

    // Type character by character with varying speeds for natural feel
    for (int i = 0; i < _characters.length && mounted; i++) {
      if (!mounted) break;

      // Variable typing speed for natural feeling
      Duration delay = _typingSpeed;

      // Slower after punctuation for natural pause
      if (i > 0) {
        final prevChar = _characters[i - 1];
        if (prevChar == '.' ||
            prevChar == '!' ||
            prevChar == '?' ||
            prevChar == '،' ||
            prevChar == '؛') {
          delay = Duration(milliseconds: _typingSpeed.inMilliseconds + 150);
        } else if (prevChar == ' ') {
          delay = Duration(milliseconds: _typingSpeed.inMilliseconds + 20);
        }
      }

      await Future.delayed(delay);

      if (mounted) {
        setState(() {
          _displayedText = _characters.take(i + 1).join();
        });
      }
    }

    // Add a small delay before completion
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        setState(() {
          _isCompleted = true;
        });
        // Call completion callback after a small delay for smooth transition
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            widget.onComplete?.call();
          }
        });
      }
    }
  }

  /// Sanitize text to prevent UTF-16 issues
  String _sanitizeText(String text) {
    try {
      return text.runes
          .where((rune) => rune != 0xFFFD && rune <= 0x10FFFF)
          .map((rune) => String.fromCharCode(rune))
          .join('')
          .replaceAll(RegExp(r'[\uD800-\uDFFF]'), '')
          .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]'), '')
          .trim();
    } catch (e) {
      // Fallback to simple filtering if advanced sanitization fails
      return text.replaceAll(
        RegExp(r'[^\x20-\x7E\u0600-\u06FF\u0750-\u077F]'),
        '',
      );
    }
  }

  @override
  void dispose() {
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _cursorAnimation,
      builder: (context, child) {
        return RichText(
          textDirection: widget.textDirection,
          textAlign: widget.textAlign,
          text: TextSpan(
            children: [
              TextSpan(
                text: _displayedText,
                style:
                    widget.textStyle ??
                    AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.8,
                      fontSize: 15.sp,
                    ),
              ),
              if (widget.showCursor && !_isCompleted)
                TextSpan(
                  text: '▊',
                  style: TextStyle(
                    color: (widget.cursorColor ?? AppColors.primary).withValues(
                      alpha: 0.3 + (_cursorAnimation.value * 0.7),
                    ),
                    fontSize: (widget.textStyle?.fontSize ?? 15.sp) * 0.9,
                    fontWeight: FontWeight.w300,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Typing animation widget with support for delayed summary display
class TypingAnimationWithSummary extends StatefulWidget {
  final String text;
  final String? summary;
  final TextStyle? textStyle;
  final Duration? typingSpeed;
  final VoidCallback? onComplete;
  final VoidCallback? onSummaryReady;
  final bool autoStart;
  final TextDirection textDirection;
  final TextAlign textAlign;
  final Color? cursorColor;
  final bool showCursor;

  const TypingAnimationWithSummary({
    super.key,
    required this.text,
    this.summary,
    this.textStyle,
    this.typingSpeed,
    this.onComplete,
    this.onSummaryReady,
    this.autoStart = true,
    this.textDirection = TextDirection.rtl,
    this.textAlign = TextAlign.right,
    this.cursorColor,
    this.showCursor = true,
  });

  @override
  State<TypingAnimationWithSummary> createState() =>
      _TypingAnimationWithSummaryState();
}

class _TypingAnimationWithSummaryState
    extends State<TypingAnimationWithSummary> {
  bool _showSummary = false;

  void _onTypingComplete() {
    // Show summary after typing is complete
    if (widget.summary != null && widget.summary!.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _showSummary = true;
          });
          widget.onSummaryReady?.call();
        }
      });
    }

    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TypingAnimationWidget(
          text: widget.text,
          textStyle: widget.textStyle,
          typingSpeed: widget.typingSpeed,
          onComplete: _onTypingComplete,
          autoStart: widget.autoStart,
          textDirection: widget.textDirection,
          textAlign: widget.textAlign,
          cursorColor: widget.cursorColor,
          showCursor: widget.showCursor,
        ),
        if (_showSummary &&
            widget.summary != null &&
            widget.summary!.isNotEmpty) ...[
          SizedBox(height: 12.h),
          AnimatedOpacity(
            opacity: _showSummary ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  width: 1.w,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.summarize_outlined,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'الملخص',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    widget.summary!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Simplified typing animation for easy use
class SimpleTypingText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  /// Duration per char
  final Duration? speed;
  final VoidCallback? onComplete;
  final TextDirection textDirection;
  final TextAlign textAlign;

  const SimpleTypingText({
    super.key,
    required this.text,
    this.style,
    this.speed,
    this.onComplete,
    this.textDirection = TextDirection.rtl,
    this.textAlign = TextAlign.right,
  });

  @override
  Widget build(BuildContext context) {
    return TypingAnimationWidget(
      text: text,
      textStyle: style,
      typingSpeed: speed,
      onComplete: onComplete,
      textDirection: textDirection,
      textAlign: textAlign,
      showCursor: true,
    );
  }
}

/// Loading dots animation for typing indicator
class TypingIndicator extends StatefulWidget {
  final Color? color;
  final double size;

  const TypingIndicator({super.key, this.color, this.size = 8.0});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 700),
        vsync: this,
      )..repeat(
        reverse: true,
        period: Duration(milliseconds: 700 + index * 140),
      ),
    );

    _animations =
        _animationControllers
            .map(
              (controller) =>
                  CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            )
            .toList();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: Opacity(
                opacity: 0.3 + (_animations[index].value * 0.7),
                child: Transform.scale(
                  scale: 0.75 + (_animations[index].value * 0.25),
                  child: Container(
                    width: widget.size.w,
                    height: widget.size.w,
                    decoration: BoxDecoration(
                      color: widget.color ?? AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
