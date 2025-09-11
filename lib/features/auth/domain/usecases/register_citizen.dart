import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:netru_app/core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterCitizenUseCase
    implements UseCase<CitizenEntity, RegisterCitizenParams> {
  final AuthRepository repository;

  RegisterCitizenUseCase(this.repository);

  @override
  Future<Either<Failure, CitizenEntity>> call(RegisterCitizenParams params) {
    return repository.registerCitizen(
      email: params.email,
      password: params.password,
      fullName: params.fullName,
      nationalId: params.nationalId,
      phone: params.phone,
      address: params.address,
    );
  }
}

class RegisterCitizenParams extends Equatable {
  final String email;
  final String password;
  final String fullName;
  final String nationalId;
  final String phone;
  final String? address;

  const RegisterCitizenParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.nationalId,
    required this.phone,
    this.address,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    fullName,
    nationalId,
    phone,
    address,
  ];
}
