import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/theme/app_colors.dart';
import 'package:netru_app/features/heatmap/presentation/pages/crime_heat_map_page.dart';
import 'package:netru_app/features/home/presentation/pages/home_screen.dart';
import 'package:netru_app/features/settings/presentation/page/settings_page.dart';
import 'package:netru_app/features/reports/presentation/pages/create_report_page.dart';
import 'package:netru_app/features/reports/presentation/pages/reports_page.dart';

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({super.key});

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CrimeHeatMapPage(),
    const CreateReportPage(),
    const ReportsPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[_selectedIndex],
      floatingActionButton:
          _selectedIndex == 0 ? const SizedBox.shrink() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        // height: 100.h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24.sp),
              label: "home".tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map, size: 24.sp),
              label: "map".tr(),
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 45.w,
                height: 45.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.add, color: Colors.white, size: 24.sp),
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined, size: 24.sp),
              label: "reports".tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined, size: 24.sp),
              label: "settings".tr(),
            ),
          ],
        ),
      ),
    );
  }
}
