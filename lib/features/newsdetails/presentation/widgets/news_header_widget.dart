import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewsHeaderWidget extends StatelessWidget {
  final String image;
  final VoidCallback? onBackPressed;

  const NewsHeaderWidget({
    super.key,
    required this.image,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height:
              MediaQuery.of(context).padding.top +
                  45.h,
          width: double.infinity,
          color: Colors.white,
          child: SafeArea(
            child: Container(
              height: 45.h,
              padding: EdgeInsets.symmetric(
                  horizontal: 12.w),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        print(
                            "Back button tapped - debugging");
                        if (onBackPressed !=
                            null) {
                          onBackPressed!();
                        } else {
                          Navigator.of(context)
                              .pop();
                        }
                      },
                      child: Container(
                        padding:
                            EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius
                                  .circular(20.r),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.black87,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: Text(
                      'جهود الأجهزة الأمنية',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18.sp,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  // مساحة فارغة لتوسيط العنوان
                  SizedBox(width: 36.w),
                ],
              ),
            ),
          ),
        ),

        // منطقة الصورة
        SizedBox(
          height: 250
              .h, // 300.h - 56.h (ارتفاع AppBar)
          width: double.infinity,
          child: Stack(
            children: [
              // الصورة الرئيسية
              Positioned.fill(
                child: Image.asset(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
