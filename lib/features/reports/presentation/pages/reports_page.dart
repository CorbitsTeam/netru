import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/di/injection_container.dart' as di;
import 'package:netru_app/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:netru_app/features/reports/presentation/cubit/reports_state.dart';
import 'package:netru_app/features/reports/presentation/widgets/report_card.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<ReportsCubit>()..loadReports(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            "reportsStatus".tr(),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
        body: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: ReportsListView(),
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
    return BlocBuilder<ReportsCubit, ReportsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage,
                  style: TextStyle(fontSize: 16.sp, color: Colors.red[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ReportsCubit>().loadReports();
                  },
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'لا توجد بلاغات متاحة',
                  style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<ReportsCubit>().loadReports(),
          child: ListView.builder(
            itemCount: state.reports.length,
            itemBuilder: (context, index) {
              final report = state.reports[index];
              return ReportCard(report: report);
            },
          ),
        );
      },
    );
  }
}
