import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:netru_app/core/services/logger_service.dart';

abstract class DatabaseDataSource {
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String? columns,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  });

  Future<Map<String, dynamic>> selectById(String table, String id);

  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data);

  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  );

  Future<void> delete(String table, String id);

  Future<int> count(String table, {Map<String, dynamic>? filters});

  Stream<List<Map<String, dynamic>>> subscribeToTable(
    String table, {
    Map<String, dynamic>? filters,
  });
}

class DatabaseDataSourceImpl implements DatabaseDataSource {
  final SupabaseClient _supabase;
  final LoggerService _logger = LoggerService();

  DatabaseDataSourceImpl({required SupabaseClient supabase})
    : _supabase = supabase;

  @override
  Future<List<Map<String, dynamic>>> select(
    String table, {
    String? columns,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      _logger.logSupabaseEvent('Database SELECT', {
        'table': table,
        'columns': columns,
        'filters': filters,
        'orderBy': orderBy,
        'limit': limit,
        'offset': offset,
      });

      final cols = columns ?? '*';
      dynamic query = _supabase.from(table).select(cols);

      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy);
      }

      // Apply pagination
      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 100) - 1);
      }

      final dynamic response = await query;

      // Normalize different response shapes from Supabase/Postgrest
      List<Map<String, dynamic>> records = [];
      if (response is List) {
        records =
            response
                .map(
                  (e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>),
                )
                .toList();
      } else if (response is Map) {
        // sometimes Supabase may return a single map
        try {
          records = [Map<String, dynamic>.from(response)];
        } catch (_) {
          records = [];
        }
      }

      _logger.logSupabaseEvent('Database SELECT successful', {
        'table': table,
        'recordCount': records.length,
      });

      return records;
    } catch (e) {
      _logger.logSupabaseEvent('Database SELECT failed', {
        'table': table,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> selectById(String table, String id) async {
    try {
      _logger.logSupabaseEvent('Database SELECT BY ID', {
        'table': table,
        'id': id,
      });

      final dynamic response =
          await _supabase.from(table).select().eq('id', id).single();

      _logger.logSupabaseEvent('Database SELECT BY ID successful', {
        'table': table,
        'id': id,
      });

      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }

      // fallback: return empty map
      return <String, dynamic>{};
    } catch (e) {
      _logger.logSupabaseEvent('Database SELECT BY ID failed', {
        'table': table,
        'id': id,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> insert(
    String table,
    Map<String, dynamic> data,
  ) async {
    try {
      _logger.logSupabaseEvent('Database INSERT', {
        'table': table,
        'data': data,
      });

      final dynamic response =
          await _supabase.from(table).insert(data).select().single();

      Map<String, dynamic> result = {};
      if (response is Map) {
        result = Map<String, dynamic>.from(response);
      }

      _logger.logSupabaseEvent('Database INSERT successful', {
        'table': table,
        'id': result['id'],
      });

      return result;
    } catch (e) {
      _logger.logSupabaseEvent('Database INSERT failed', {
        'table': table,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      _logger.logSupabaseEvent('Database UPDATE', {
        'table': table,
        'id': id,
        'data': data,
      });

      final dynamic response =
          await _supabase
              .from(table)
              .update(data)
              .eq('id', id)
              .select()
              .single();

      _logger.logSupabaseEvent('Database UPDATE successful', {
        'table': table,
        'id': id,
      });

      if (response is Map) {
        return Map<String, dynamic>.from(response);
      }

      return <String, dynamic>{};
    } catch (e) {
      _logger.logSupabaseEvent('Database UPDATE failed', {
        'table': table,
        'id': id,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<void> delete(String table, String id) async {
    try {
      _logger.logSupabaseEvent('Database DELETE', {'table': table, 'id': id});

      await _supabase.from(table).delete().eq('id', id);

      _logger.logSupabaseEvent('Database DELETE successful', {
        'table': table,
        'id': id,
      });
    } catch (e) {
      _logger.logSupabaseEvent('Database DELETE failed', {
        'table': table,
        'id': id,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Future<int> count(String table, {Map<String, dynamic>? filters}) async {
    try {
      _logger.logSupabaseEvent('Database COUNT', {
        'table': table,
        'filters': filters,
      });

      var query = _supabase.from(table).select('*');

      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.eq(entry.key, entry.value);
        }
      }

      final dynamic response = await query;

      int count = 0;
      if (response is List) {
        count = response.length;
      } else {
        count = 0;
      }

      _logger.logSupabaseEvent('Database COUNT successful', {
        'table': table,
        'count': count,
      });

      return count;
    } catch (e) {
      _logger.logSupabaseEvent('Database COUNT failed', {
        'table': table,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> subscribeToTable(
    String table, {
    Map<String, dynamic>? filters,
  }) {
    try {
      _logger.logSupabaseEvent('Database SUBSCRIBE', {
        'table': table,
        'filters': filters,
      });

      final subscription = _supabase.from(table).stream(primaryKey: ['id']);

      return subscription.map((dynamic data) {
        try {
          final list =
              (data as List)
                  .map((item) => Map<String, dynamic>.from(item as Map))
                  .toList();
          _logger.logSupabaseEvent('Database SUBSCRIPTION UPDATE', {
            'table': table,
            'recordCount': list.length,
          });
          return list;
        } catch (_) {
          return <Map<String, dynamic>>[];
        }
      });
    } catch (e) {
      _logger.logSupabaseEvent('Database SUBSCRIBE failed', {
        'table': table,
        'error': e.toString(),
      });
      rethrow;
    }
  }
}
