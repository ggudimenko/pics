import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pics/bloc/auth_bloc.dart';
import 'package:pics/bloc/login_bloc.dart';
import 'package:pics/bloc/login_event.dart';
import 'package:pics/bloc/login_state.dart';
import 'package:pics/presentation/widgets/loading_indicator_widget.dart';
import 'package:pinput/pin_put/pin_put.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginBloc, LoginState>(listener: (context, loginState) {
      if (loginState is ExceptionState || loginState is OtpExceptionState) {
        String message = "";
        if (loginState is ExceptionState) {
          message = loginState.message;
        } else if (loginState is OtpExceptionState) {
          message = loginState.message;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(message),
            ),
          );
      }
    }, builder: (context, state) {
      return Scaffold(
          body: CustomScrollView(slivers: <Widget>[
        const SliverAppBar(
            floating: false,
            automaticallyImplyLeading: false,
            pinned: true,
            elevation: 0,
            leadingWidth: 0,
            title: Text('Login by phone')),
        SliverFillRemaining(
          child: Padding(padding: EdgeInsets.only(top: 40, left: 20, right: 20), child: getViewAsPerState(state)),
        ),
      ]));
    });
  }

  getViewAsPerState(LoginState state) {
    if (state is UnAuthenticated) {
      return NumberInput();
    } else if (state is OtpSentState || state is OtpExceptionState) {
      return OtpInput();
    } else if (state is LoadingState) {
      return LoadingIndicatorWidget();
    } else if (state is LoginCompleteState) {
      BlocProvider.of<AuthBloc>(context).add(LoggedIn(token: state.getUser().uid));
    } else {
      return NumberInput();
    }
  }
}

class NumberInput extends StatelessWidget {
  NumberInput({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _phoneTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const Text("Enter your mobile phone number:"),
        SizedBox(height: 20),
        Form(
          key: _formKey,
          child: TextFormField(
              decoration: const InputDecoration(
                  hintText: "79048447703",
                  alignLabelWithHint: true,
                  prefixText: "+",
                  floatingLabelBehavior: FloatingLabelBehavior.always),
              controller: _phoneTextController,
              keyboardType: TextInputType.number,
              validator: (value) {
                return validateMobile(value ?? "");
              }),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                BlocProvider.of<LoginBloc>(context).add(SendOtpEvent(phoNo: "+" + _phoneTextController.value.text));
              }
            },
            child: Text("Submit"),
          ),
        )
      ],
    );
  }

  String? validateMobile(String value) {
    String pattern = r'[0-9]{11}';
    RegExp regExp = RegExp(pattern);
    if (value.isEmpty) {
      return 'Please enter mobile number';
    } else if (!regExp.hasMatch(value)) {
      return 'Phone number must consists 11 digits';
    }
    return null;
  }
}

class OtpInput extends StatelessWidget {
  const OtpInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var _pinPutDecoration = BoxDecoration(
      border: Border.all(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(15.0),
    );

    return Column(
      children: <Widget>[
        const Text("Enter one-time password from SMS:"),
        SizedBox(height: 20),
        PinPut(
          autofocus: true,
          fieldsCount: 6,
          followingFieldDecoration: _pinPutDecoration,
          submittedFieldDecoration: _pinPutDecoration.copyWith(
            borderRadius: BorderRadius.circular(20.0),
          ),
          selectedFieldDecoration: _pinPutDecoration.copyWith(
              borderRadius: BorderRadius.circular(20.0), color: Theme.of(context).secondaryHeaderColor),
          onSubmit: (String pin) {
            BlocProvider.of<LoginBloc>(context).add(VerifyOtpEvent(otp: pin));
          },
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: ElevatedButton(
            onPressed: () {
              BlocProvider.of<LoginBloc>(context).add(EditPhoneEvent());
            },
            child: const Text("Edit phone"),
          ),
        )
      ],
    );
  }
}
