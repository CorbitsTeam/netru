import 'package:equatable/equatable.dart';
import '../../data/models/case_model.dart';

abstract class CasesState extends Equatable {
  const CasesState();

  @override
  List<Object?> get props => [];
}

class CasesInitial extends CasesState {}

class CasesLoading extends CasesState {}

class LatestCasesLoaded extends CasesState {
  final List<CaseModel> cases;

  const LatestCasesLoaded({required this.cases});

  @override
  List<Object?> get props => [cases];
}

class TrendingCasesLoaded extends CasesState {
  final List<CaseModel> cases;

  const TrendingCasesLoaded({required this.cases});

  @override
  List<Object?> get props => [cases];
}

class CaseDetailsLoaded extends CasesState {
  final CaseModel caseModel;

  const CaseDetailsLoaded({required this.caseModel});

  @override
  List<Object?> get props => [caseModel];
}

class CasesError extends CasesState {
  final String message;

  const CasesError({required this.message});

  @override
  List<Object> get props => [message];
}
