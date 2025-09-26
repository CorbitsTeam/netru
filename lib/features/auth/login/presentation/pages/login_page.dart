import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/extensions/navigation_extensions.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/user_data_helper.dart';
import '../../../domain/entities/user_entity.dart';
import '../cubit/login_cubit.dart';
import '../cubit/login_state.dart';
import '../widgets/login_header.dart';
import '../widgets/login_tab_bar.dart';
import '../widgets/login_bottom_section.dart';
import '../widgets/citizen_login_form.dart';
import '../widgets/foreigner_login_form.dart';
import '../widgets/admin_login_form.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() =>
      _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  bool _showAdminTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12.r,
          ),
        ),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _navigateToSignup() {
    context.pushNamed(Routes.signupScreen);
  }

  void _navigateBasedOnUserType(
    UserEntity user,
  ) async {
    // Save user data to SharedPreferences and refresh from database
    try {
      final userHelper = UserDataHelper();
      await userHelper.saveCurrentUser(user);

      // Refresh user data from database to get complete information
      await userHelper
          .refreshUserDataFromDatabase();
    } catch (e) {
      print(
        'Error saving/refreshing user data: $e',
      );
    }

    switch (user.userType) {
      case UserType.citizen:
      case UserType.foreigner:
        context.pushReplacementNamed(
          Routes.customBottomBar,
        );
        break;
      case UserType.admin:
        context.pushReplacementNamed(
          Routes.adminDashboard,
        );
        break;
    }
  }

  void _onLogoDoubleTap() {
    if (!_showAdminTab) {
      setState(() {
        _showAdminTab = true;
        // Dispose the old controller properly
        final oldIndex = _tabController.index;
        _tabController.dispose();
        _tabController = TabController(
          length: 3,
          vsync: this,
        );
        // Keep the current tab if it's still valid, otherwise go to admin tab
        if (oldIndex < 2) {
          _tabController.index = oldIndex;
        } else {
          _tabController.animateTo(
            2,
          ); // Switch to admin tab
        }
      });
    }
  }

  void _handleFormSubmit() {
    // This will be handled by individual form widgets
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoginLoading) {
            setState(() => _isLoading = true);
          } else {
            setState(() => _isLoading = false);
          }

          if (state is LoginSuccess) {
            _navigateBasedOnUserType(state.user);
          } else if (state is LoginFailure) {
            _showErrorSnackBar(state.error);
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24.w,
            ),
            child: Column(
              children: [
                SizedBox(height: 40.h),
                LoginHeader(
                  onLogoDoubleTap:
                      _onLogoDoubleTap,
                ),

                SizedBox(
                  height:
                      MediaQuery.of(
                        context,
                      ).size.height *
                      0.4,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      CitizenLoginForm(
                        isLoading: _isLoading,
                        onSubmit:
                            _handleFormSubmit,
                      ),
                      ForeignerLoginForm(
                        isLoading: _isLoading,
                        onSubmit:
                            _handleFormSubmit,
                      ),
                      if (_showAdminTab)
                        AdminLoginForm(
                          isLoading: _isLoading,
                          onSubmit:
                              _handleFormSubmit,
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 65.h),
                LoginBottomSection(
                  onSignupTap: _navigateToSignup,
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
