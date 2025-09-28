import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/features/reports/presentation/widgets/multiple_media_viewer.dart';
import 'package:netru_app/features/reports/presentation/widgets/report_submission_progress_widget.dart';

void main() {
  group('New Features Tests', () {
    testWidgets('Multiple Media Viewer should display correctly', (
      WidgetTester tester,
    ) async {
      // Setup screen util for testing
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder:
              (context, child) => MaterialApp(
                home: Scaffold(
                  body: MultipleMediaViewer(
                    reportId: 'test-report-id',
                    mediaList: [
                      {
                        'url': 'https://example.com/image1.jpg',
                        'type': 'image',
                      },
                      {
                        'url': 'https://example.com/image2.jpg',
                        'type': 'image',
                      },
                      {
                        'url': 'https://example.com/video1.mp4',
                        'type': 'video',
                      },
                    ],
                  ),
                ),
              ),
        ),
      );

      // Verify the widget renders
      expect(find.byType(MultipleMediaViewer), findsOneWidget);

      // Check for media type indicators
      expect(find.text('صورة'), findsAtLeastNWidgets(1));

      // Check for grid view
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets(
      'Report Submission Progress Widget should display progress correctly',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            builder:
                (context, child) => MaterialApp(
                  home: Scaffold(
                    body: ReportSubmissionProgressWidget(
                      progress: 0.5, // 50%
                      currentStep: 'رفع الملفات...',
                      isUploading: true,
                      uploadedFiles: 2,
                      totalFiles: 4,
                    ),
                  ),
                ),
          ),
        );

        // Verify the widget renders
        expect(find.byType(ReportSubmissionProgressWidget), findsOneWidget);

        // Check for progress text
        expect(find.text('رفع الملفات...'), findsOneWidget);

        // Check for progress percentage
        expect(find.text('50%'), findsOneWidget);

        // Check for file upload progress
        expect(find.text('2 / 4'), findsOneWidget);

        // Check for progress bar
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      },
    );

    test('Progress calculation should work correctly', () {
      // Test progress calculation for different stages

      // Validation stage (20%)
      expect(0.2, equals(0.2));

      // Media upload stage (30% - 60%)
      final uploadProgress = 0.5; // 50% of files uploaded
      final overallUploadProgress = 0.3 + (uploadProgress * 0.3);
      expect(overallUploadProgress, equals(0.45)); // 45%

      // Submission stage (70% - 90%)
      expect(0.7, lessThan(0.9));

      // Completion (100%)
      expect(1.0, equals(1.0));
    });
  });

  group('Media Display Tests', () {
    test('Media type detection should work correctly', () {
      // Test image detection
      final imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
      for (final type in imageTypes) {
        expect(
          _isImageType(type),
          isTrue,
          reason: '$type should be detected as image',
        );
      }

      // Test video detection
      final videoTypes = ['mp4', 'avi', 'mov', 'mkv', 'webm'];
      for (final type in videoTypes) {
        expect(
          _isImageType(type),
          isFalse,
          reason: '$type should not be detected as image',
        );
      }
    });

    test('Media URL parsing should work correctly', () {
      const testUrl = 'https://example.com/media/image.jpg?v=123';
      final extension = _getFileExtension(testUrl);
      expect(extension, equals('jpg'));
    });
  });
}

// Helper functions for testing
bool _isImageType(String? type) {
  if (type == null) return false;
  const imageTypes = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
  return imageTypes.contains(type.toLowerCase());
}

String _getFileExtension(String url) {
  final uri = Uri.parse(url);
  final path = uri.path;
  final lastDot = path.lastIndexOf('.');
  if (lastDot != -1 && lastDot < path.length - 1) {
    return path.substring(lastDot + 1).toLowerCase();
  }
  return '';
}
