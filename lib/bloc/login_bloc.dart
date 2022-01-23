import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pics/bloc/login_state.dart';
import 'package:pics/bloc/login_event.dart';
import 'package:pics/data/repositories/auth_repository.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthRepository authRepository;
  String verID = "";
  StreamSubscription? subscription;

  LoginBloc({required this.authRepository}) : super(InitialLoginState()) {
    on<SendOtpEvent>((event, emit) async {
      emit(LoadingState());
      subscription = sendOtp(event.phoNo).listen((event) {
        add(event);
      });
    });

    on<EditPhoneEvent>((event, emit) async {
      emit(InitialLoginState());
    });

    on<OtpSendEvent>((event, emit) async {
      emit(OtpSentState());
    });

    on<LoginCompleteEvent>((event, emit) async {
      emit(LoginCompleteState(event.firebaseUser));
    });

    on<LoginExceptionEvent>((event, emit) async {
      emit(ExceptionState(message: event.message));
    });

    on<VerifyOtpEvent>((event, emit) async {
      emit(LoadingState());
      try {
        UserCredential result =
            await authRepository.verifyAndLogin(verID, event.otp);
        if (result.user != null) {
          emit(LoginCompleteState(result.user as User));
        } else {
          emit(OtpExceptionState(message: "⚠️ Invalid one-time password"));
        }
      } catch (e) {
        emit(OtpExceptionState(message: "⚠️ Invalid one-time password"));
        print(e);
      }
    });
  }

  @override
  void onEvent(LoginEvent event) {
    super.onEvent(event);
    print(event);
  }

  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
    print(stacktrace);
  }

  @override
  Future<void> close() async {
    print("Bloc closed");
    super.close();
  }

  Stream<LoginEvent> sendOtp(String phoNo) async* {
    StreamController<LoginEvent> eventStream = StreamController();
    final phoneVerificationCompleted = (PhoneAuthCredential authCredential) {
      var user = authRepository.getUser() as User;

      eventStream.add(LoginCompleteEvent(user));
      eventStream.close();
    };
    final phoneVerificationFailed = (FirebaseAuthException authException) {
      print(authException.message);
      eventStream.add(LoginExceptionEvent(onError.toString()));
      eventStream.close();
    };
    final phoneCodeSent = (String verId, int? forceResent) {
      verID = verId;
      eventStream.add(OtpSendEvent());
    };
    final phoneCodeAutoRetrievalTimeout = (String verid) {
      verID = verid;
      eventStream.close();
    };

    await authRepository.sendOtp(
        phoNo,
        Duration(seconds: 100),
        phoneVerificationFailed,
        phoneVerificationCompleted,
        phoneCodeSent,
        phoneCodeAutoRetrievalTimeout);

    yield* eventStream.stream;
  }
}