import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/di/injection_container.dart'
    as di;
import 'package:netru_app/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:netru_app/features/reports/presentation/cubit/reports_state.dart';
import 'package:netru_app/features/reports/presentation/widgets/report_card.dart';
import 'package:netru_app/features/reports/presentation/widgets/reports_loading_widget.dart';
import 'package:netru_app/features/reports/presentation/widgets/reports_error_widget.dart';
import 'package:netru_app/features/reports/presentation/widgets/reports_empty_state_widget.dart';
import 'package:netru_app/features/reports/presentation/widgets/reports_summary_header.dart';
import 'package:netru_app/core/theme/app_colors.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              di.sl<ReportsCubit>()
                ..loadReports(),
      child: Scaffold(
        backgroundColor:
            Theme.of(
              context,
            ).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor:
              Theme.of(
                context,
              ).scaffoldBackgroundColor,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(
                    context,
                  ).scaffoldBackgroundColor,
            ),
          ),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "بلاغاتي",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          actions: [
            BlocBuilder<
              ReportsCubit,
              ReportsState
            >(
              builder: (context, state) {
                return Container(
                  margin: EdgeInsets.only(
                    right: 16.w,
                  ),
                  child: IconButton(
                    onPressed: () {
                      context
                          .read<ReportsCubit>()
                          .loadReports();
                    },
                    icon: Icon(
                      Icons.refresh,
                      color:
                          AppColors.primaryColor,
                      size: 24.sp,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context)
                    .scaffoldBackgroundColor
                    .withValues(alpha: 0.2),
                Theme.of(
                  context,
                ).scaffoldBackgroundColor,
              ],
            ),
          ),
          child: const SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: ReportsListView(),
            ),
          ),
        ),
      ),
    );
  }
}

class ReportsListView extends StatelessWidget {
  const ReportsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      ReportsCubit,
      ReportsState
    >(
      builder: (context, state) {
        if (state.isLoading) {
          return const ReportsLoadingWidget();
        }

        if (state.errorMessage.isNotEmpty) {
          return ReportsErrorWidget(
            errorMessage: state.errorMessage,
            onRetry: () => context.read<ReportsCubit>().loadReports(),
          );
        }

        if (state.reports.isEmpty) {
          return const ReportsEmptyStateWidget();
        }

        return RefreshIndicator(
          onRefresh:
              () =>
                  context
                      .read<ReportsCubit>()
                      .loadReports(),
          color: AppColors.primaryColor,
          backgroundColor: Colors.white,
          child: Column(
            children: [
              // Summary header
              ReportsSummaryHeader(
                reportsCount: state.reports.length,
              ),

              // Reports list
              Expanded(
                child: ListView.builder(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  itemCount: state.reports.length,
                  itemBuilder: (context, index) {
                    final report =
                        state.reports[index];
                    return ReportCard(
                      report: report,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
