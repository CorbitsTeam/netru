import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants/app_assets.dart';

enum ViewState { loading, error, empty, success }

class HandleDataView extends StatelessWidget {
  final ViewState state;
  final Widget successWidget;
  final String? errorMessage;

  const HandleDataView({
    super.key,
    required this.state,
    required this.successWidget,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case ViewState.loading:
        return const Center(child: CustomImageLoading());
      case ViewState.error:
        return Center(
          child: Column(
            children: [
              Lottie.asset(AppAssets.lottieServer),
              24.verticalSpace,
              Text(errorMessage ?? "حدث خطأ ما 😢"),
            ],
          ),
        );
      case ViewState.empty:
        return Center(
          child: Column(
            children: [
              Lottie.asset(AppAssets.lottieEmpty),
              24.verticalSpace,
              const Text("لا توجد بيانات 😶"),
            ],
          ),
        );
      case ViewState.success:
        return successWidget;
    }
  }
}

class CustomImageLoading extends StatefulWidget {
  final String? message;
  final double? size;

  const CustomImageLoading({super.key, this.message, this.size = 150});

  @override
  State<CustomImageLoading> createState() => _CustomImageLoadingState();
}

class _CustomImageLoadingState extends State<CustomImageLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _tiltAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _tiltAnimation = Tween<double>(
      begin: -0.03,
      end: 0.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _tiltAnimation.value,
                  child: child,
                ),
              );
            },
            child: Image.asset(
              AppAssets.mainLogo,
              width: widget.size,
              height: widget.size,
            ),
          ),
          20.verticalSpace,
          Text(
            widget.message ?? "loading".tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          60.verticalSpace,
        ],
      ),
    );
  }
}
