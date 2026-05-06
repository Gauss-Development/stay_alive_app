import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/gamification/domain/usecases/get_gamification_progress_usecase.dart';
import 'package:stay_alive/features/gamification/presentation/cubit/gamification_state.dart';

class GamificationCubit extends Cubit<GamificationState> {
  GamificationCubit({
    required GetGamificationProgressUseCase getGamificationProgressUseCase,
  })  : _getGamificationProgressUseCase = getGamificationProgressUseCase,
        super(const GamificationInitial());

  final GetGamificationProgressUseCase _getGamificationProgressUseCase;

  Future<void> load() async {
    emit(const GamificationLoading());
    final result = await _getGamificationProgressUseCase(const NoParams());
    result.fold(
      (failure) => emit(GamificationError(failure.message)),
      (progress) => emit(GamificationLoaded(progress)),
    );
  }

  Future<void> refresh() async {
    final result = await _getGamificationProgressUseCase(const NoParams());
    result.fold(
      (failure) => emit(GamificationError(failure.message)),
      (progress) => emit(GamificationLoaded(progress)),
    );
  }
}
