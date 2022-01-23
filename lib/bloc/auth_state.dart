part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class InitialAuthenticationState extends AuthState {}

class Uninitialized extends AuthState {}

class Authenticated extends AuthState {
  final User _firebaseUser;

  Authenticated(this._firebaseUser);

  User getUser() {
    return _firebaseUser;
  }

  @override
  List<Object> get props => [_firebaseUser];
}

class UnAuthenticated extends AuthState {}

class Loading extends AuthState {}
