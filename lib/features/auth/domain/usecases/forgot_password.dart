// import 'package:dartz/dartz.dart';
// import 'package:equatable/equatable.dart';
// import '../../../../core/errors/failures.dart';
// import '../../../../core/usecases/usecase.dart';
// import '../repositories/auth_repository.dart';

// /// Legacy forgot password use case - now calls sendPasswordResetEmail
// /// This is kept for backward compatibility but uses the new Supabase email flow
// class ForgotPasswordUseCase implements UseCase<bool, ForgotPasswordParams> {
//   final AuthRepository repository;

//   ForgotPasswordUseCase(this.repository);

//   @override
//   Future<Either<Failure, bool>> call(ForgotPasswordParams params) async {
//     return await repository.sendPasswordResetEmail(params.email);
//   }
// }

// class ForgotPasswordParams extends Equatable {
//   final String email;

//   const ForgotPasswordParams({required this.email});

//   @override
//   List<Object> get props => [email];
// }
