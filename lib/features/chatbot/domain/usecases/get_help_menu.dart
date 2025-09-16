import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/chat_repository.dart';

class GetHelpMenuUseCase implements UseCase<String, NoParams> {
  final ChatRepository repository;

  const GetHelpMenuUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(NoParams params) async {
    return await repository.getHelpMenu();
  }
}
