import 'package:equatable/equatable.dart';

/// بيانات التسجيل متعدد الخطوات
class SignupStepData extends Equatable {
  final UserType userType;
  final Map<String, dynamic> data;
  final int currentStep;
  final int totalSteps;
  final bool isCompleted;

  const SignupStepData({
    required this.userType,
    required this.data,
    required this.currentStep,
    required this.totalSteps,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [
    userType,
    data,
    currentStep,
    totalSteps,
    isCompleted,
  ];

  SignupStepData copyWith({
    UserType? userType,
    Map<String, dynamic>? data,
    int? currentStep,
    int? totalSteps,
    bool? isCompleted,
  }) {
    return SignupStepData(
      userType: userType ?? this.userType,
      data: data ?? this.data,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_type': userType.name,
      'data': data,
      'current_step': currentStep,
      'total_steps': totalSteps,
      'is_completed': isCompleted,
    };
  }

  factory SignupStepData.fromMap(Map<String, dynamic> map) {
    return SignupStepData(
      userType: UserType.values.firstWhere(
        (e) => e.name == map['user_type'],
        orElse: () => UserType.citizen,
      ),
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      currentStep: map['current_step'] ?? 1,
      totalSteps: map['total_steps'] ?? 4,
      isCompleted: map['is_completed'] ?? false,
    );
  }

  factory SignupStepData.initial({required UserType userType}) {
    return SignupStepData(
      userType: userType,
      data: const {},
      currentStep: 1,
      totalSteps: 4,
    );
  }

  bool get canProceedToNext => currentStep < totalSteps;
  bool get canGoBack => currentStep > 1;
  double get progress => currentStep / totalSteps;
}

enum UserType { citizen, foreigner, admin }

/// نتيجة التحقق من OTP
class OtpVerificationResult extends Equatable {
  final bool isValid;
  final String? error;
  final String? token;

  const OtpVerificationResult({required this.isValid, this.error, this.token});

  @override
  List<Object?> get props => [isValid, error, token];

  factory OtpVerificationResult.success({String? token}) {
    return OtpVerificationResult(isValid: true, token: token);
  }

  factory OtpVerificationResult.failure({required String error}) {
    return OtpVerificationResult(isValid: false, error: error);
  }
}

/// بيانات تسجيل الدخول بالمحمول والـ OTP
class PhoneLoginData extends Equatable {
  final String phoneNumber;
  final String? countryCode;
  final String? otp;
  final bool otpSent;
  final bool otpVerified;
  final DateTime? otpSentAt;

  const PhoneLoginData({
    required this.phoneNumber,
    this.countryCode,
    this.otp,
    this.otpSent = false,
    this.otpVerified = false,
    this.otpSentAt,
  });

  @override
  List<Object?> get props => [
    phoneNumber,
    countryCode,
    otp,
    otpSent,
    otpVerified,
    otpSentAt,
  ];

  PhoneLoginData copyWith({
    String? phoneNumber,
    String? countryCode,
    String? otp,
    bool? otpSent,
    bool? otpVerified,
    DateTime? otpSentAt,
  }) {
    return PhoneLoginData(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      otp: otp ?? this.otp,
      otpSent: otpSent ?? this.otpSent,
      otpVerified: otpVerified ?? this.otpVerified,
      otpSentAt: otpSentAt ?? this.otpSentAt,
    );
  }

  String get fullPhoneNumber => '${countryCode ?? '+20'}$phoneNumber';

  bool get canRequestOtp => phoneNumber.isNotEmpty && !otpSent;
  bool get canVerifyOtp => otpSent && otp != null && otp!.length >= 4;
  bool get isOtpExpired {
    if (otpSentAt == null) return false;
    return DateTime.now().difference(otpSentAt!).inMinutes > 5;
  }
}
