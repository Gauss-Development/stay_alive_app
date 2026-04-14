import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stay_alive/core/usecase/usecase.dart';
import 'package:stay_alive/features/user/domain/usecases/get_user_profile_usecase.dart';
import 'package:stay_alive/features/user/presentation/cubit/user_profile_state.dart';

class UserProfileCubit extends Cubit<UserProfileState> {
  UserProfileCubit({
    required GetUserProfileUseCase getUserProfileUseCase,
  })  : _getUserProfileUseCase = getUserProfileUseCase,
        super(const UserProfileInitial());

  final GetUserProfileUseCase _getUserProfileUseCase;

  Future<void> load() async {
    emit(const UserProfileLoading());
    final result = await _getUserProfileUseCase(const NoParams());
    result.fold(
      (failure) => emit(UserProfileError(failure.message)),
      (profile) => emit(UserProfileLoaded(profile)),
    );
  }
}
