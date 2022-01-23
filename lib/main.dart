import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pics/bloc/auth_bloc.dart';
import 'package:pics/bloc/login_bloc.dart';
import 'package:pics/bloc/pics_bloc.dart';
import 'package:pics/data/repositories/auth_repository.dart';
import 'package:pics/presentation/screens/login_page.dart';
import 'package:pics/presentation/screens/pics_page.dart';
import 'package:pics/presentation/screens/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return RepositoryProvider(
        create: (context) => AuthRepository(),
        child: MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (context) => AuthBloc(
                      authRepository:
                      RepositoryProvider.of<AuthRepository>(context))
                    ..add(AppStarted())),
              BlocProvider(
                  create: (context) => PicsBloc(
                      authRepository:
                          RepositoryProvider.of<AuthRepository>(context))),
              BlocProvider(
                  create: (context) => LoginBloc(
                      authRepository:
                          RepositoryProvider.of<AuthRepository>(context))),
            ],
            child: MaterialApp(
                title: 'Pics',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  primarySwatch: Colors.blue,
                ),
                home: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    if (state is Uninitialized) {
                      return SplashPage();
                    } else if (state is UnAuthenticated) {
                      return LoginPage();
                    } else if (state is Authenticated) {
                      BlocProvider.of<PicsBloc>(context)
                          .add(ReloadRequest());
                      return PicsPage();
                    } else {
                      return SplashPage();
                    }
                  },
                ))));
  }
}
