import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterForeignerUseCase
    implements UseCase<ForeignerEntity, RegisterForeignerParams> {
  final AuthRepository repository;

  RegisterForeignerUseCase(this.repository);

  @override
  Future<Either<Failure, ForeignerEntity>> call(
    RegisterForeignerParams params,
  ) async {
    return await repository.registerForeigner(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      passportNumber: params.passportNumber,
      nationality: params.nationality,
      phone: params.phone,
    );
  }
}

class RegisterForeignerParams extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String passportNumber;
  final String nationality;
  final String phone;

  const RegisterForeignerParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.passportNumber,
    required this.nationality,
    required this.phone,
  });

  @override
  List<Object> get props => [
    email,
    password,
    fullName,
    passportNumber,
    nationality,
    phone,
  ];
}
