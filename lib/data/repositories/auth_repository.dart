import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pics/data/data_providers/firestore_data_provider.dart';
import 'package:pics/data/models/user.dart' as model_user;

class AuthRepository {
  final _firebaseAuth = FirebaseAuth.instance;
  final FirestoreDataProvider firestoreDataProvider = FirestoreDataProvider();

  model_user.User? _currentUser;

  model_user.User? get currentUser => _currentUser;

  Future<void> sendOtp(
      String phoneNumber,
      Duration timeOut,
      PhoneVerificationFailed phoneVerificationFailed,
      PhoneVerificationCompleted phoneVerificationCompleted,
      PhoneCodeSent phoneCodeSent,
      PhoneCodeAutoRetrievalTimeout autoRetrievalTimeout) async {
    _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeOut,
        verificationCompleted: phoneVerificationCompleted,
        verificationFailed: phoneVerificationFailed,
        codeSent: phoneCodeSent,
        codeAutoRetrievalTimeout: autoRetrievalTimeout);
  }

  Future<UserCredential> verifyAndLogin(String verificationId, String smsCode) async {
    AuthCredential authCredential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

    var userCredential = await _firebaseAuth.signInWithCredential(authCredential);

    // todo обработать когда user = null
    if (userCredential.user != null) {
      _currentUser = model_user.User(ts: Timestamp.fromDate(DateTime.now()), id: userCredential.user!.uid);
      await firestoreDataProvider.createUser(_currentUser!);
    }

    return userCredential;
  }

  User? getUser() {
    return _firebaseAuth.currentUser;
  }

  Future populateCurrentUser(User? user) async {
    if (user != null) {
      _currentUser = await firestoreDataProvider.getUser(user.uid);
    }
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception(e);
    }
  }
}
