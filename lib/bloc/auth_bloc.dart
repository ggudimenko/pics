import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'package:pics/data/repositories/auth_repository.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(Uninitialized()) {
    on<AppStarted>((event, emit) async {
      final User? firebaseUser = authRepository.getUser();
      if (firebaseUser != null) {
        //todo ниже может быть ошибка, надо обработать
        await authRepository.populateCurrentUser(firebaseUser);
        emit(Authenticated(firebaseUser));
      } else {
        emit(UnAuthenticated());
      }
    });

    on<LoggedIn>((event, emit) async {
      emit(Loading());
      final User firebaseUser = authRepository.getUser() as User;
      emit(Authenticated(firebaseUser));

    });

    on<LoggedOut>((event, emit) async {
      emit(Loading());
      emit(UnAuthenticated());
    });
  }
}
