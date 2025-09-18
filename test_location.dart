import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netru_app/core/services/location_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        title: 'اختبار الموقع المصري - مدينة نصر 🇪🇬',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: LocationTestScreen(),
      ),
    );
  }
}

class LocationTestScreen extends StatefulWidget {
  @override
  _LocationTestScreenState createState() => _LocationTestScreenState();
}

class _LocationTestScreenState extends State<LocationTestScreen> {
  String locationText =
      'اضغط "تحديد الموقع" للحصول على موقعك في مدينة نصر 🇪🇬';
  double? latitude;
  double? longitude;
  String? locationName;
  bool isLoading = false;

  void _testLocation() async {
    setState(() {
      isLoading = true;
      locationText = 'جاري تحديد الموقع...';
    });

    try {
      final locationService = LocationService();

      // الحصول على الموقع الحالي
      final location = await locationService.getCurrentLocation();

      if (location != null) {
        latitude = location.latitude;
        longitude = location.longitude;

        // الحصول على تفاصيل العنوان
        final locationResult = await locationService.getLocationByCoordinates(
          location.latitude,
          location.longitude,
        );

        locationResult.fold(
          (failure) {
            setState(() {
              locationText =
                  'فشل في الحصول على تفاصيل الموقع: ${failure.message}';
            });
          },
          (locationDetails) {
            setState(() {
              locationName = locationDetails.displayName;
              locationText = '''
الموقع تم تحديده بنجاح:
العنوان: ${locationDetails.displayName}
الشارع: ${locationDetails.street ?? 'غير محدد'}
المدينة: ${locationDetails.city ?? 'غير محدد'}
المحافظة: ${locationDetails.state ?? 'غير محدد'}
الدولة: ${locationDetails.country ?? 'غير محدد'}
الإحداثيات: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}
              ''';
            });
          },
        );
      } else {
        setState(() {
          locationText = 'فشل في الحصول على الموقع. تأكد من تفعيل GPS والإذن';
        });
      }
    } catch (e) {
      setState(() {
        locationText = 'خطأ: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openMap() async {
    if (latitude != null && longitude != null) {
      try {
        await LocationService.openInGoogleMaps(latitude!, longitude!);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('تم فتح الخرائط بنجاح')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل في فتح الخرائط: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لا توجد إحداثيات متاحة'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اختبار الموقع الحقيقي'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // زر تحديد الموقع
            ElevatedButton.icon(
              onPressed: isLoading ? null : _testLocation,
              icon:
                  isLoading
                      ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Icon(Icons.location_on),
              label: Text(
                isLoading ? 'جاري التحديد...' : 'تحديد الموقع الحقيقي',
                style: TextStyle(fontSize: 16.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),

            SizedBox(height: 20.h),

            // زر فتح الخرائط (يظهر فقط عند وجود إحداثيات)
            if (latitude != null && longitude != null) ...[
              ElevatedButton.icon(
                onPressed: _openMap,
                icon: Icon(Icons.map),
                label: Text(
                  'فتح في خرائط جوجل',
                  style: TextStyle(fontSize: 16.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
              SizedBox(height: 20.h),
            ],

            // عرض نتائج الموقع
            Expanded(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.grey[50],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    locationText,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
