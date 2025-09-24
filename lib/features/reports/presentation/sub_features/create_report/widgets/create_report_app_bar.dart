import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateReportAppBar extends StatelessWidget {
  final VoidCallback onHelpPressed;

  const CreateReportAppBar({super.key, required this.onHelpPressed});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 40.h,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'تقديم بلاغ',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.black),
          onPressed: onHelpPressed,
        ),
      ],
    );
  }
}
