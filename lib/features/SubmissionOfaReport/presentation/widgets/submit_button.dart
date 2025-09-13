import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/cubit/submission_report_cubit.dart';
import 'package:netru_app/features/SubmissionOfaReport/presentation/cubit/submission_report_state.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onSubmit;

  const SubmitButton({
    super.key,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // // Info text
        // Container(
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: Colors.amber[50],
        //     borderRadius: BorderRadius.circular(
        //       12,
        //     ),
        //     border: Border.all(
        //       color: Colors.amber[200]!,
        //       width: 1,
        //     ),
        //   ),
        //   child: Row(
        //     children: [
        //       Icon(
        //         Icons.info_outline,
        //         color: Colors.amber[700],
        //         size: 20,
        //       ),
        //       const SizedBox(width: 8),
        //       Expanded(
        //         child: Column(
        //           crossAxisAlignment:
        //               CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               'معلومات مهمة',
        //               style: TextStyle(
        //                 fontSize: 14,
        //                 fontWeight:
        //                     FontWeight.w600,
        //                 color: Colors.amber[800],
        //               ),
        //             ),
        //             const SizedBox(height: 2),
        //             Text(
        //               'تأكد من صحة جميع البيانات قبل الإرسال',
        //               style: TextStyle(
        //                 fontSize: 12,
        //                 color: Colors.amber[700],
        //               ),
        //             ),
        //           ],
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        // SizedBox(height: 10.h),
        // Submit Button
        BlocBuilder<
          ReportFormCubit,
          ReportFormState
        >(
          builder: (context, state) {
            return SizedBox(
              width: double.infinity,
              height: 40.h,
              child: ElevatedButton(
                onPressed:
                    state.isLoading
                        ? null
                        : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF1E3A8A,
                  ),
                  disabledBackgroundColor:
                      Colors.grey[300],
                  elevation:
                      state.isLoading ? 0 : 2,
                  shadowColor: const Color(
                    0xFF1E3A8A,
                  ).withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                          4.r,
                        ),
                  ),
                ),
                child:
                    state.isLoading
                        ? Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                    color:
                                        Colors
                                            .white,
                                    strokeWidth:
                                        2,
                                  ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Text(
                              'جاري الإرسال...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color:
                                    Colors
                                        .grey[600],
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            const Text(
                              'إرسال البلاغ',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight
                                        .w600,
                                color:
                                    Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
              ),
            );
          },
        ),
      ],
    );
  }
}
