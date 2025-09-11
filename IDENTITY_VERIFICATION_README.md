# Identity Verification Module Documentation

## Overview

This documentation covers the complete **Identity Verification Module** for the Netru Flutter app, built following Clean Architecture principles with Supabase integration.

## Features

✅ **Document Scanning**: Camera-based scanning for Egyptian National ID and Foreign Passports  
✅ **OCR Extraction**: Automatic text extraction with confidence scoring  
✅ **Supabase Integration**: Secure storage and authentication  
✅ **Clean Architecture**: Domain/Data/Presentation layer separation  
✅ **State Management**: Bloc/Cubit pattern implementation  
✅ **Multi-language Support**: Arabic and English UI  
✅ **Security**: Row Level Security (RLS) policies  
✅ **Audit Trail**: Comprehensive logging system  

## Setup Instructions

### 1. Database Setup

Execute the database schema in your Supabase project:

```sql
-- Run the complete schema from:
-- database/identity_verification_schema.sql
```

This creates:
- `identity_documents` table
- `verification_logs` table  
- Row Level Security policies
- Storage bucket policies
- Automated triggers and functions

### 2. Dependency Installation

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  # Core Flutter packages
  flutter_bloc: ^8.1.3
  get_it: ^7.6.4
  equatable: ^2.0.5
  dartz: ^0.10.1
  logger: ^2.0.2+1
  
  # UI packages
  flutter_screenutil: ^5.9.0
  
  # Supabase integration
  supabase_flutter: ^2.0.0
  
  # Camera and ML
  camera: ^0.10.5+5
  google_ml_kit: ^0.16.0
  image: ^4.1.3
  path_provider: ^2.1.1
  permission_handler: ^11.0.1
  
  # Image processing
  image_picker: ^1.0.4
```

### 3. Initialize Dependencies

```dart
// In your main.dart
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // Initialize dependency injection
  await initializeDependencies();
  
  runApp(MyApp());
}
```

### 4. Camera Permissions

Add camera permissions to your platform files:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan identity documents</string>
```

## Architecture Overview

### Domain Layer
```
lib/features/verification/domain/
├── entities/
│   ├── identity_document.dart
│   └── extracted_document_data.dart
├── repositories/
│   └── verification_repository.dart
└── use_cases/
    ├── scan_document.dart
    ├── save_identity_document.dart
    ├── get_user_documents.dart
    └── check_verification_status.dart
```

### Data Layer
```
lib/features/verification/data/
├── models/
│   ├── identity_document_model.dart
│   └── extracted_document_data_model.dart
├── data_sources/
│   ├── verification_remote_data_source.dart
│   └── document_scanner_service.dart
└── repositories/
    └── verification_repository_impl.dart
```

### Presentation Layer
```
lib/features/verification/presentation/
├── cubit/
│   ├── verification_cubit.dart
│   └── verification_state.dart
├── pages/
│   ├── document_scan_page.dart
│   └── profile_page.dart
└── widgets/
    ├── document_type_selector.dart
    ├── camera_view_widget.dart
    ├── scan_preview_widget.dart
    ├── verification_success_widget.dart
    ├── verification_status_widget.dart
    └── documents_list_widget.dart
```

## Usage Examples

### Basic Integration

```dart
// Navigate to document scanning
VerificationNavigationHelper.navigateToDocumentScan(context);

// Check verification status
context.read<VerificationCubit>().checkVerificationStatus(userId);

// Wrap features that require verification
VerificationGate(
  featureName: 'report_incident',
  userId: currentUserId,
  child: ReportIncidentButton(),
)
```

### State Management

```dart
BlocBuilder<VerificationCubit, VerificationState>(
  builder: (context, state) {
    if (state is DocumentScanned) {
      return ScanPreviewWidget(
        extractedData: state.extractedData,
        imageFile: state.imageFile,
      );
    } else if (state is VerificationLoading) {
      return CircularProgressIndicator();
    } else if (state is VerificationError) {
      return ErrorWidget(state.message);
    }
    return DocumentScanPage();
  },
)
```

## API Reference

### VerificationCubit Methods

```dart
// Scan a document with camera
void scanDocument(DocumentType type, File imageFile)

// Save scanned document to database
void saveDocument(IdentityDocument document)

// Get user's uploaded documents
void getUserDocuments(String userId)

// Check verification status
void checkVerificationStatus(String userId)

// Delete a document
void deleteDocument(String documentId)
```

### DocumentType Enum

```dart
enum DocumentType {
  nationalId,    // Egyptian National ID
  passport,      // Foreign Passport
}
```

### DocumentStatus Enum

```dart
enum DocumentStatus {
  pending,       // Awaiting review
  approved,      // Verified and approved  
  rejected,      // Rejected due to issues
  expired,       // Document has expired
}
```

## Database Schema

### Tables

#### identity_documents
- `id`: UUID primary key
- `user_id`: UUID foreign key to auth.users
- `document_type`: Document type (national_id/passport)
- `document_number`: Extracted document number
- `full_name`: Extracted full name
- `date_of_birth`: Extracted birth date
- `expiry_date`: Document expiry date
- `nationality`: Extracted nationality
- `status`: Verification status
- `image_url`: Supabase Storage URL
- `confidence_score`: OCR confidence (0-1)
- `created_at`: Timestamp
- `updated_at`: Timestamp

#### verification_logs
- `id`: UUID primary key
- `document_id`: Foreign key to identity_documents
- `action`: Log action type
- `details`: JSON details
- `performed_by`: User who performed action
- `performed_at`: Timestamp

### Security Policies

- **Row Level Security (RLS)** enabled on all tables
- Users can only access their own documents
- Admin users can access all documents for review
- Automatic audit logging for all operations

## Troubleshooting

### Common Issues

1. **Camera Permission Denied**
   ```dart
   // Check and request permissions
   final status = await Permission.camera.request();
   if (status != PermissionStatus.granted) {
     // Handle permission denial
   }
   ```

2. **OCR Low Confidence**
   - Ensure good lighting conditions
   - Document should be flat and clear
   - Minimum confidence threshold is 0.7

3. **Supabase Storage Upload Errors**
   - Check storage bucket policies
   - Verify file size limits (max 10MB)
   - Ensure proper authentication

4. **Database RLS Errors**
   - Verify user is authenticated
   - Check RLS policies are correctly applied
   - Ensure proper user_id is being used

### Debug Mode

Enable detailed logging:

```dart
// In your dependency injection setup
Logger.level = Level.ALL; // Enable all log levels
```

## Testing

### Unit Tests
```bash
flutter test test/features/verification/
```

### Integration Tests
```bash
flutter test integration_test/verification_flow_test.dart
```

### Manual Testing Checklist

- [ ] Camera opens and displays preview
- [ ] Document type selection works
- [ ] OCR extracts text correctly
- [ ] Document saves to Supabase
- [ ] Verification status updates
- [ ] RLS policies work correctly
- [ ] Error handling displays properly
- [ ] Multi-language support works

## Performance Considerations

1. **Image Optimization**: Images are compressed before upload
2. **Caching**: OCR results are cached to avoid reprocessing
3. **Background Processing**: Heavy operations run in isolates
4. **Memory Management**: Large images are disposed properly

## Security Notes

1. **Data Encryption**: All data encrypted in transit and at rest
2. **Access Control**: RLS policies restrict data access
3. **Audit Trail**: All actions are logged for compliance
4. **PII Handling**: Personal data is handled per privacy regulations

## Future Enhancements

- [ ] AI-powered document validation
- [ ] Real-time verification status updates
- [ ] Batch document processing
- [ ] Advanced fraud detection
- [ ] Biometric verification integration

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review Supabase logs
3. Enable debug logging
4. Contact development team

---

**Version**: 1.0.0  
**Last Updated**: December 2024  
**Compatible with**: Flutter 3.16+, Supabase 2.0+
