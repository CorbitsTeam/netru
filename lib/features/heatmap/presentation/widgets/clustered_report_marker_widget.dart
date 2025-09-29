import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/heatmap_entity.dart';
import '../helpers/report_marker_helper.dart';

/// Custom widget for clustered reports (multiple reports in the same area)
class ClusteredReportMarkerWidget extends StatefulWidget {
  final List<ReportLocationEntity> reports;
  final VoidCallback? onTap;

  const ClusteredReportMarkerWidget({
    super.key,
    required this.reports,
    this.onTap,
  });

  @override
  State<ClusteredReportMarkerWidget> createState() =>
      _ClusteredReportMarkerWidgetState();
}

class _ClusteredReportMarkerWidgetState
    extends State<ClusteredReportMarkerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.elasticOut,
      ),
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  /// Get the highest priority from all reports in the cluster
  String _getHighestPriority() {
    if (widget.reports.any((r) => r.priority == 'urgent')) return 'urgent';
    if (widget.reports.any((r) => r.priority == 'high')) return 'high';
    return 'medium';
  }

  /// Get the most common report type in the cluster
  String _getDominantReportType() {
    final typeCount = <String, int>{};
    for (final report in widget.reports) {
      typeCount[report.reportType] = (typeCount[report.reportType] ?? 0) + 1;
    }
    return typeCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get cluster size based on report count
  double _getClusterSize() {
    final count = widget.reports.length;
    if (count >= 20) return 60.w;
    if (count >= 10) return 52.w;
    if (count >= 5) return 46.w;
    return 40.w;
  }

  /// Get font size based on report count
  double _getFontSize() {
    final count = widget.reports.length;
    if (count >= 100) return 12.sp;
    if (count >= 20) return 14.sp;
    if (count >= 10) return 16.sp;
    return 14.sp;
  }

  @override
  Widget build(BuildContext context) {
    final highestPriority = _getHighestPriority();
    final dominantType = _getDominantReportType();
    final color = ReportMarkerHelper.getClusterColor(widget.reports.length, highestPriority);
    final icon = ReportMarkerHelper.getReportIcon(dominantType);
    final clusterSize = _getClusterSize();
    final fontSize = _getFontSize();

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Enhanced multi-layer glow for urgent/high priority clusters
                if (highestPriority == 'urgent' || highestPriority == 'high')
                  ...[
                    // Outermost glow
                    Container(
                      width: clusterSize + 20.w,
                      height: clusterSize + 20.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.08),
                      ),
                    ),
                    // Middle glow
                    Container(
                      width: clusterSize + 12.w,
                      height: clusterSize + 12.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.12),
                      ),
                    ),
                    // Inner glow
                    Container(
                      width: clusterSize + 6.w,
                      height: clusterSize + 6.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.18),
                      ),
                    ),
                  ],

                // Enhanced shadow layer with multiple shadows
                Container(
                  width: clusterSize,
                  height: clusterSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      // Primary shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 3,
                        offset: const Offset(0, 6),
                      ),
                      // Secondary shadow for depth
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 3),
                      ),
                      // Color shadow for emphasis
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),

                // Main circular background with enhanced gradient
                Container(
                  width: clusterSize,
                  height: clusterSize,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topLeft,
                      radius: 1.2,
                      colors: [
                        color,
                        color.withValues(alpha: 0.9),
                        color.withValues(alpha: 0.75),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 4,
                    ),
                  ),
                ),

                // Inner ring for better definition
                Container(
                  width: clusterSize - 8.w,
                  height: clusterSize - 8.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                ),

                // Content
                SizedBox(
                  width: clusterSize - 8.w,
                  height: clusterSize - 8.h,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Icon(
                        icon,
                        color: Colors.white,
                        size: (clusterSize * 0.35),
                      ),
                      SizedBox(height: 2.h),
                      // Count
                      Text(
                        widget.reports.length.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                // Priority indicator for urgent clusters
                if (highestPriority == 'urgent')
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 16.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: color,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.warning_rounded,
                          color: Colors.red,
                          size: 10.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}