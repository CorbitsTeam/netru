import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import '../../../cubit/reports_cubit.dart';
import '../../../cubit/reports_state.dart';
import '../../../widgets/report_card.dart';
import 'reports_loading_widget.dart';
import 'reports_error_widget.dart';
import 'reports_empty_widget.dart';
import 'reports_summary_header.dart';

class ReportsListWidget extends StatelessWidget {
  const ReportsListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const ReportsLoadingWidget();
        }

        if (state.errorMessage.isNotEmpty) {
          return ReportsErrorWidget(errorMessage: state.errorMessage);
        }

        if (state.reports.isEmpty) {
          return const ReportsEmptyWidget();
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ReportsCubit>().loadReports(),
          color: AppColors.primaryColor,
          backgroundColor: Colors.white,
          child: Column(
            children: [
              ReportsSummaryHeader(reportsCount: state.reports.length),
              Expanded(
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: state.reports.length,
                  itemBuilder: (context, index) {
                    final report = state.reports[index];
                    return ReportCard(report: report);
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
