import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/routing/routes.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/identity_document.dart';
import '../cubit/verification_cubit.dart';
import '../cubit/verification_state.dart';
import '../widgets/document_type_selector.dart';
import '../widgets/camera_view_widget.dart';
import '../widgets/scan_preview_widget.dart';
import '../widgets/verification_success_widget.dart';

class DocumentScanPage extends StatefulWidget {
  const DocumentScanPage({super.key});

  @override
  State<DocumentScanPage> createState() => _DocumentScanPageState();
}

class _DocumentScanPageState extends State<DocumentScanPage> {
  DocumentType? _selectedDocumentType;
  File? _capturedImage;
  late CameraController _cameraController;
  bool _isCameraInitialized = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('التحقق من الهوية'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<VerificationCubit, VerificationState>(
        listener: (context, state) {
          if (state is VerificationProcessFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red,
              ),
            );
          } else if (state is VerificationProcessSuccess) {
            // Navigate to success page or profile
            context.pushNamed(Routes.profile);
          }
        },
        builder: (context, state) {
          if (state is VerificationProcessInProgress) {
            return _buildLoadingView(state.currentStep);
          } else if (state is DocumentScanSuccess) {
            return _buildScanPreview(state);
          } else if (state is VerificationProcessSuccess) {
            return _buildSuccessView(state);
          }

          return _buildMainView();
        },
      ),
    );
  }

  Widget _buildMainView() {
    if (_selectedDocumentType == null) {
      return _buildDocumentTypeSelection();
    }

    if (_capturedImage == null) {
      return _buildCameraView();
    }

    return _buildImagePreview();
  }

  Widget _buildDocumentTypeSelection() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryColor.withOpacity(0.1),
                  AppColors.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user,
                    color: Colors.white,
                    size: 30.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التحقق من الهوية',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'يرجى اختيار نوع الوثيقة للتحقق من هويتك',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),

          Text(
            'اختر نوع الوثيقة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 16.h),

          DocumentTypeSelector(
            onDocumentTypeSelected: (type) {
              setState(() {
                _selectedDocumentType = type;
              });
            },
          ),

          const Spacer(),

          // Instructions
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[600],
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'تعليمات مهمة',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  '• تأكد من وضوح الوثيقة والإضاءة الجيدة\n'
                  '• تجنب الظلال والانعكاسات\n'
                  '• اجعل الوثيقة مسطحة ومستقيمة\n'
                  '• تأكد من ظهور جميع التفاصيل',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.blue[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    if (!_isCameraInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            SizedBox(height: 16.h),
            Text(
              'جاري تشغيل الكاميرا...',
              style: TextStyle(fontSize: 16.sp, color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return CameraViewWidget(
      cameraController: _cameraController,
      documentType: _selectedDocumentType!,
      onCapture: (imageFile) {
        setState(() {
          _capturedImage = imageFile;
        });
      },
      onGalleryPick: _pickFromGallery,
      onBack: () {
        setState(() {
          _selectedDocumentType = null;
        });
      },
    );
  }

  Widget _buildImagePreview() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معاينة الصورة',
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),

          // Image preview
          Container(
            width: double.infinity,
            height: 300.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Image.file(_capturedImage!, fit: BoxFit.cover),
            ),
          ),

          SizedBox(height: 24.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _capturedImage = null;
                    });
                  },
                  child: const Text('إعادة التصوير'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _processDocument,
                  child: const Text('تأكيد ومتابعة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanPreview(DocumentScanSuccess state) {
    return ScanPreviewWidget(
      extractedData: state.extractedData,
      onConfirm: () => _saveDocument(state.extractedData),
      onRetry: () {
        context.read<VerificationCubit>().reset();
        setState(() {
          _capturedImage = null;
        });
      },
    );
  }

  Widget _buildLoadingView(String currentStep) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(AppAssets.lottieLoading, width: 150.w, height: 150.h),
            SizedBox(height: 24.h),
            Text(
              currentStep,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Text(
              'يرجى الانتظار...',
              style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(VerificationProcessSuccess state) {
    return VerificationSuccessWidget(
      document: state.document,
      extractedData: state.extractedData,
      onContinue: () {
        context.pushNamed(Routes.profile);
      },
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _capturedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في اختيار الصورة: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  void _processDocument() {
    if (_capturedImage != null && _selectedDocumentType != null) {
      context.read<VerificationCubit>().scanDocument(
        imageFile: _capturedImage!,
        documentType: _selectedDocumentType!,
      );
    }
  }

  void _saveDocument(extractedData) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<VerificationCubit>().completeVerificationProcess(
        imageFile: _capturedImage!,
        documentType: _selectedDocumentType!,
        userId: authState.user.id,
      );
    }
  }
}
