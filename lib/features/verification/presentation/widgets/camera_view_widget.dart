import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/identity_document.dart';

class CameraViewWidget extends StatefulWidget {
  final CameraController cameraController;
  final DocumentType documentType;
  final Function(File) onCapture;
  final VoidCallback onGalleryPick;
  final VoidCallback onBack;

  const CameraViewWidget({
    super.key,
    required this.cameraController,
    required this.documentType,
    required this.onCapture,
    required this.onGalleryPick,
    required this.onBack,
  });

  @override
  State<CameraViewWidget> createState() => _CameraViewWidgetState();
}

class _CameraViewWidgetState extends State<CameraViewWidget> {
  bool _isCapturing = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera preview
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CameraPreview(widget.cameraController),
        ),

        // Overlay for document frame
        _buildDocumentOverlay(),

        // Top controls
        Positioned(
          top: 60.h,
          left: 16.w,
          right: 16.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: widget.onBack,
                icon: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  _getDocumentTypeName(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 48), // Placeholder for symmetry
            ],
          ),
        ),

        // Instructions
        Positioned(
          top: 120.h,
          left: 16.w,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.center_focus_strong,
                  color: Colors.white,
                  size: 24.sp,
                ),
                SizedBox(height: 8.h),
                Text(
                  'ضع الوثيقة داخل الإطار',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4.h),
                Text(
                  'تأكد من وضوح النص والإضاءة الجيدة',
                  style: TextStyle(color: Colors.white70, fontSize: 12.sp),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),

        // Bottom controls
        Positioned(
          bottom: 80.h,
          left: 0,
          right: 0,
          child: _buildBottomControls(),
        ),
      ],
    );
  }

  Widget _buildDocumentOverlay() {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CustomPaint(
        painter: DocumentFramePainter(documentType: widget.documentType),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Gallery button
          IconButton(
            onPressed: widget.onGalleryPick,
            icon: Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library,
                color: Colors.white,
                size: 28.sp,
              ),
            ),
          ),

          // Capture button
          GestureDetector(
            onTap: _isCapturing ? null : _captureImage,
            child: Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: _isCapturing ? Colors.grey : AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child:
                  _isCapturing
                      ? SizedBox(
                        width: 24.w,
                        height: 24.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                      : Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 32.sp,
                      ),
            ),
          ),

          // Flash button (placeholder)
          IconButton(
            onPressed: () {
              // Toggle flash functionality can be added here
            },
            icon: Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.flash_off, color: Colors.white, size: 28.sp),
            ),
          ),
        ],
      ),
    );
  }

  String _getDocumentTypeName() {
    switch (widget.documentType) {
      case DocumentType.nationalId:
        return 'بطاقة الرقم القومي';
      case DocumentType.passport:
        return 'جواز السفر';
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final XFile image = await widget.cameraController.takePicture();
      widget.onCapture(File(image.path));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في التقاط الصورة: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      setState(() {
        _isCapturing = false;
      });
    }
  }
}

class DocumentFramePainter extends CustomPainter {
  final DocumentType documentType;

  DocumentFramePainter({required this.documentType});

  @override
  void paint(Canvas canvas, Size size) {
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.5);

    // Calculate document frame dimensions
    final frameWidth = size.width * 0.8;
    final frameHeight =
        documentType == DocumentType.nationalId
            ? frameWidth *
                0.63 // Standard ID card ratio
            : frameWidth * 0.7; // Passport ratio

    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = (size.height - frameHeight) / 2;

    final frameRect = Rect.fromLTWH(
      frameLeft,
      frameTop,
      frameWidth,
      frameHeight,
    );

    // Draw overlay (everything except the frame)
    final overlayPath =
        Path()
          ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
          ..addRRect(
            RRect.fromRectAndRadius(frameRect, const Radius.circular(12)),
          )
          ..fillType = PathFillType.evenOdd;

    canvas.drawPath(overlayPath, overlayPaint);

    // Draw frame corners
    const cornerLength = 30.0;
    final cornerPaint =
        Paint()
          ..color = AppColors.primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    // Top-left corner
    canvas.drawLine(
      Offset(frameLeft, frameTop + cornerLength),
      Offset(frameLeft, frameTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop),
      Offset(frameLeft + cornerLength, frameTop),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(frameLeft + frameWidth - cornerLength, frameTop),
      Offset(frameLeft + frameWidth, frameTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameWidth, frameTop),
      Offset(frameLeft + frameWidth, frameTop + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(frameLeft, frameTop + frameHeight - cornerLength),
      Offset(frameLeft, frameTop + frameHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop + frameHeight),
      Offset(frameLeft + cornerLength, frameTop + frameHeight),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(frameLeft + frameWidth - cornerLength, frameTop + frameHeight),
      Offset(frameLeft + frameWidth, frameTop + frameHeight),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameLeft + frameWidth, frameTop + frameHeight),
      Offset(frameLeft + frameWidth, frameTop + frameHeight - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
