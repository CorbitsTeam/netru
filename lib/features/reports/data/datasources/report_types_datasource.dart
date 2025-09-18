import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/report_type_model.dart';

abstract class ReportTypesDataSource {
  Future<List<ReportTypeModel>> getAllReportTypes();
  Future<ReportTypeModel?> getReportTypeById(int id);
}

class ReportTypesDataSourceImpl implements ReportTypesDataSource {
  final SupabaseClient supabaseClient;

  ReportTypesDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ReportTypeModel>> getAllReportTypes() async {
    try {
      final response = await supabaseClient
          .from('report_types')
          .select()
          .eq('is_active', true)
          .order('name_ar');

      return (response as List)
          .map((json) => ReportTypeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch report types: $e');
    }
  }

  @override
  Future<ReportTypeModel?> getReportTypeById(int id) async {
    try {
      final response =
          await supabaseClient
              .from('report_types')
              .select()
              .eq('id', id)
              .single();

      return ReportTypeModel.fromJson(response);
    } catch (e) {
      // Return null if not found instead of throwing
      return null;
    }
  }
}
