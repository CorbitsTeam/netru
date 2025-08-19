import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/constants/app_constants.dart';
import 'package:netru_app/features/home/presentation/pages/home_screen.dart';
import 'package:netru_app/features/reports/presentation/pages/reports_page.dart';

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({super.key});

  @override
  State<CustomBottomBar> createState() =>
      _CustomBottomBarState();
}

class _CustomBottomBarState
    extends State<CustomBottomBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text("الخريطه")),
    const Center(child: Text("إضافة")),
    const ReportsPage(),
    const Center(child: Text("الإعدادات")),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: SizedBox(
        height: 105.h,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor:
              AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "home".tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: "map".tr(),
            ),
            BottomNavigationBarItem(
              icon: Container(
                width: 50.w,
                height: 50.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xff0A2C64),
                ),
                child: Icon(Icons.add,
                    color: Colors.white,
                    size: 30.sp),
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.help_outlined),
              label: "reports".tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "settings".tr(),
            ),
          ],
        ),
      ),
    );
  }
}
