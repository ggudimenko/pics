

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class EditPhoneEvent extends LoginEvent {}

class SendOtpEvent extends LoginEvent {
  String phoNo;

  SendOtpEvent({required this.phoNo});
}

class VerifyOtpEvent extends LoginEvent {
  String otp;

  VerifyOtpEvent({required this.otp});
}

class LogoutEvent extends LoginEvent {}

class OtpSendEvent extends LoginEvent {}

class LoginCompleteEvent extends LoginEvent {
  final User firebaseUser;
  LoginCompleteEvent(this.firebaseUser);
}

class LoginExceptionEvent extends LoginEvent {
  String message;

  LoginExceptionEvent(this.message);
}