import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Enhanced typing animation widget with improved effects and performance
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
  final bool enableWaveEffect;
  final bool enableProgressIndicator;
  final double? progress; // For streaming mode

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
    this.enableWaveEffect = true,
    this.enableProgressIndicator = false,
    this.progress,
  });

  @override
  State<TypingAnimationWidget> createState() => _TypingAnimationWidgetState();
}

class _TypingAnimationWidgetState extends State<TypingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _cursorController;
  late AnimationController _waveController;
  late AnimationController _progressController;
  late Animation<double> _cursorAnimation;
  late Animation<double> _waveAnimation;
  late Animation<double> _progressAnimation;

  String _displayedText = '';
  bool _isCompleted = false;
  List<String> _words = [];
  double _currentProgress = 0.0;
  bool _isAnimating = false;

  Duration get _typingSpeed =>
      widget.typingSpeed ?? const Duration(milliseconds: 12);

  Duration get _wordSpeed =>
      Duration(milliseconds: (_typingSpeed.inMilliseconds * 0.8).round());

  @override
  void initState() {
    super.initState();

    // Initialize cursor blinking animation
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _cursorAnimation = CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeInOut,
    );

    // Initialize wave effect animation
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _waveAnimation = CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    );

    // Initialize progress animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
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
      _words = [];
      _currentProgress = 0.0;
      _isAnimating = false;
      if (widget.autoStart) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _startTyping();
        });
      }
    }

    // Handle streaming progress updates
    if (widget.progress != null && widget.progress != _currentProgress) {
      setState(() {
        _currentProgress = widget.progress!;
      });
      if (widget.enableProgressIndicator) {
        _progressController.animateTo(widget.progress!);
      }
    }
  }

  void _startTyping() async {
    if (_isAnimating) return;

    setState(() {
      _displayedText = '';
      _isCompleted = false;
      _currentProgress = 0.0;
      _isAnimating = true;
    });

    // Sanitize text to prevent UTF-16 issues
    final sanitizedText = _sanitizeText(widget.text);
    if (sanitizedText.isEmpty) {
      _completeTyping();
      return;
    }

    // Split into words for more natural typing
    _words = sanitizedText.split(RegExp(r'(\s+)'));

    // Use word-by-word animation for better performance
    await _typeByWords();

    // Complete the animation
    _completeTyping();
  }

  Future<void> _typeByWords() async {
    for (int i = 0; i < _words.length && mounted && _isAnimating; i++) {
      if (!mounted) break;

      final word = _words[i];
      final isSpace = word.trim().isEmpty;

      // Calculate delay based on content
      Duration delay = _calculateWordDelay(word, i);

      // Update progress
      final progress = (i + 1) / _words.length;

      if (widget.enableProgressIndicator) {
        _progressController.animateTo(progress);
      }

      // Add word to display with smooth animation
      await _addWordWithAnimation(word, delay);

      // Update current progress
      setState(() {
        _currentProgress = progress;
      });

      // Small pause for natural feel
      if (!isSpace && i < _words.length - 1) {
        await Future.delayed(
          Duration(milliseconds: _wordSpeed.inMilliseconds ~/ 3),
        );
      }
    }
  }

  Future<void> _addWordWithAnimation(String word, Duration delay) async {
    if (!mounted || !_isAnimating) return;

    setState(() {
      _displayedText += word;
    });

    await Future.delayed(delay);
  }

  Duration _calculateWordDelay(String word, int index) {
    // Base delay
    var baseDelay = _wordSpeed.inMilliseconds;

    // Longer pause after punctuation
    if (word.contains(RegExp(r'[.!?؟।॥]'))) {
      baseDelay = (baseDelay * 2.5).round();
    } else if (word.contains(RegExp(r'[,،;؛:]'))) {
      baseDelay = (baseDelay * 1.5).round();
    } else if (word.trim().isEmpty) {
      baseDelay = (baseDelay * 0.3).round();
    }

    // Add slight randomization for natural feel (±20%)
    final randomFactor = 0.8 + (0.4 * (index % 5) / 5);
    baseDelay = (baseDelay * randomFactor).round();

    return Duration(milliseconds: baseDelay.clamp(5, 500));
  }

  void _completeTyping() {
    if (!mounted) return;

    setState(() {
      _isCompleted = true;
      _isAnimating = false;
      _currentProgress = 1.0;
    });

    if (widget.enableProgressIndicator) {
      _progressController.animateTo(1.0);
    }

    // Call completion callback with smooth transition
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        widget.onComplete?.call();
      }
    });
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
    _waveController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress indicator (if enabled)
        if (widget.enableProgressIndicator && _isAnimating)
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                child: LinearProgressIndicator(
                  value: _progressAnimation.value,
                  backgroundColor: AppColors.border,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 2.h,
                ),
              );
            },
          ),

        // Main text content with enhanced animations
        AnimatedBuilder(
          animation: Listenable.merge([
            _cursorAnimation,
            if (widget.enableWaveEffect) _waveAnimation,
          ]),
          builder: (context, child) {
            return Container(
              decoration:
                  widget.enableWaveEffect && _isAnimating
                      ? BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(
                              alpha: 0.1 + (_waveAnimation.value * 0.15),
                            ),
                            blurRadius: 3 + (_waveAnimation.value * 2),
                            offset: Offset(0, 1.h),
                          ),
                        ],
                      )
                      : null,
              child: RichText(
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
                            height: 1.6,
                            fontSize: 15.sp,
                          ),
                    ),
                    if (widget.showCursor && !_isCompleted)
                      TextSpan(
                        text: '▊',
                        style: TextStyle(
                          color: (widget.cursorColor ?? AppColors.primary)
                              .withValues(
                                alpha: 0.4 + (_cursorAnimation.value * 0.6),
                              ),
                          fontSize:
                              (widget.textStyle?.fontSize ?? 15.sp) * 0.95,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // Completion indicator
        if (_isCompleted && widget.enableWaveEffect)
          AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              margin: EdgeInsets.only(top: 4.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 12.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'تم',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.success,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Enhanced typing animation widget with support for delayed summary display and streaming
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
  final bool enableWaveEffect;
  final bool isStreaming;
  final double? progress;

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
    this.enableWaveEffect = true,
    this.isStreaming = false,
    this.progress,
  });

  @override
  State<TypingAnimationWithSummary> createState() =>
      _TypingAnimationWithSummaryState();
}

class _TypingAnimationWithSummaryState extends State<TypingAnimationWithSummary>
    with TickerProviderStateMixin {
  bool _showSummary = false;
  late AnimationController _summaryController;
  late Animation<double> _summaryAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize summary animation
    _summaryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _summaryAnimation = CurvedAnimation(
      parent: _summaryController,
      curve: Curves.easeOutBack,
    );

    // Initialize pulse animation for streaming
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    if (widget.isStreaming) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(TypingAnimationWithSummary oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle streaming state changes
    if (oldWidget.isStreaming != widget.isStreaming) {
      if (widget.isStreaming) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onTypingComplete() {
    // Show summary after typing is complete
    if (widget.summary != null && widget.summary!.isNotEmpty) {
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _showSummary = true;
          });
          _summaryController.forward();
          widget.onSummaryReady?.call();
        }
      });
    }

    // Stop pulse animation when typing is complete
    if (widget.isStreaming) {
      _pulseController.stop();
      _pulseController.reset();
    }

    widget.onComplete?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Streaming indicator
        if (widget.isStreaming)
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(
                          alpha: 0.4 + (_pulseAnimation.value * 0.6),
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'جارٍ الكتابة...',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary.withValues(
                          alpha: 0.6 + (_pulseAnimation.value * 0.4),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

        // Main typing animation
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
          enableWaveEffect: widget.enableWaveEffect,
          enableProgressIndicator: widget.text.length > 200,
          progress: widget.progress,
        ),

        // Enhanced summary section
        if (_showSummary &&
            widget.summary != null &&
            widget.summary!.isNotEmpty)
          ..._buildEnhancedSummary(),
      ],
    );
  }

  List<Widget> _buildEnhancedSummary() {
    return [
      SizedBox(height: 16.h),
      AnimatedBuilder(
        animation: _summaryAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _summaryAnimation.value,
            child: Opacity(
              opacity: _summaryAnimation.value,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryLight.withValues(alpha: 0.15),
                      AppColors.primaryLight.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.4),
                    width: 1.w,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8.r,
                      offset: Offset(0, 2.h),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Icon(
                            Icons.auto_awesome,
                            size: 16.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'الملخص الذكي',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    SelectableText(
                      widget.summary!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ];
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

/// Enhanced loading dots animation for typing indicator
class TypingIndicator extends StatefulWidget {
  final Color? color;
  final double size;
  final int dotCount;
  final Duration animationDuration;

  const TypingIndicator({
    super.key,
    this.color,
    this.size = 8.0,
    this.dotCount = 3,
    this.animationDuration = const Duration(milliseconds: 1200),
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _opacityAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationControllers = List.generate(
      widget.dotCount,
      (index) =>
          AnimationController(duration: widget.animationDuration, vsync: this)
            ..repeat(),
    );

    _scaleAnimations =
        _animationControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;

          // Stagger the animations
          final begin = (index * 0.2) % 1.0;
          final end = (begin + 0.6) % 1.0;

          return TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(
                begin: 0.7,
                end: 1.2,
              ).chain(CurveTween(curve: Curves.easeOut)),
              weight: 30,
            ),
            TweenSequenceItem(
              tween: Tween<double>(
                begin: 1.2,
                end: 0.7,
              ).chain(CurveTween(curve: Curves.easeIn)),
              weight: 30,
            ),
            TweenSequenceItem(tween: ConstantTween<double>(0.7), weight: 40),
          ]).animate(
            CurvedAnimation(
              parent: controller,
              curve: Interval(begin, end, curve: Curves.easeInOut),
            ),
          );
        }).toList();

    _opacityAnimations =
        _animationControllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;

          // Stagger the opacity animations
          final begin = (index * 0.15) % 1.0;
          final end = (begin + 0.7) % 1.0;

          return TweenSequence<double>([
            TweenSequenceItem(
              tween: Tween<double>(begin: 0.3, end: 1.0),
              weight: 35,
            ),
            TweenSequenceItem(
              tween: Tween<double>(begin: 1.0, end: 0.3),
              weight: 35,
            ),
            TweenSequenceItem(tween: ConstantTween<double>(0.3), weight: 30),
          ]).animate(
            CurvedAnimation(
              parent: controller,
              curve: Interval(begin, end, curve: Curves.easeInOut),
            ),
          );
        }).toList();

    // Start animations with slight delays for wave effect
    for (int i = 0; i < _animationControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _animationControllers[i].repeat();
        }
      });
    }
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
      children: List.generate(widget.dotCount, (index) {
        return AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimations[index],
            _opacityAnimations[index],
          ]),
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.w),
              child: Transform.scale(
                scale: _scaleAnimations[index].value,
                child: Opacity(
                  opacity: _opacityAnimations[index].value,
                  child: Container(
                    width: widget.size.w,
                    height: widget.size.w,
                    decoration: BoxDecoration(
                      color: widget.color ?? AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.color ?? AppColors.primary).withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 2.r,
                          offset: Offset(0, 1.h),
                        ),
                      ],
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
