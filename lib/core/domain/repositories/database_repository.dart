import 'package:dartz/dartz.dart';
import '../../errors/failures.dart';

abstract class DatabaseRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> select(
    String table, {
    String? columns,
    Map<String, dynamic>? filters,
    String? orderBy,
    int? limit,
    int? offset,
  });

  Future<Either<Failure, Map<String, dynamic>>> selectById(
    String table,
    String id,
  );

  Future<Either<Failure, Map<String, dynamic>>> insert(
    String table,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, Map<String, dynamic>>> update(
    String table,
    String id,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, void>> delete(String table, String id);

  Future<Either<Failure, int>> count(
    String table, {
    Map<String, dynamic>? filters,
  });

  Stream<List<Map<String, dynamic>>> subscribeToTable(
    String table, {
    Map<String, dynamic>? filters,
  });
}
