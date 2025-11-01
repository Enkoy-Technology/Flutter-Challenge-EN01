import 'package:enkoy_chat/app/app.locator.dart';
import 'package:enkoy_chat/interfaces/iauth.interface.dart';
import 'package:enkoy_chat/models/UserAccount.dart';
import 'package:enkoy_chat/ui/common/app_constant.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';

class SignupViewModel extends BaseViewModel {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _authService = locator<IAuthService>();

  String _email = "";
  String _password = "";
  String _rePassword = "";
  String _firstName = "";

  bool _showPasswordOne = false;
  bool _showPasswordTwo = false;

  bool get showPasswordOne => _showPasswordOne;
  bool get showPasswordTwo => _showPasswordTwo;

  toggleShowPasswordOne() {
    _showPasswordOne = !_showPasswordOne;
    rebuildUi();
  }

  toggleShowPasswordTwo() {
    _showPasswordTwo = !_showPasswordTwo;
    rebuildUi();
  }

  onChangeFirstName(String? val) {
    _firstName = val!;
  }

  onChangeEmail(String? val) {
    _email = val!;
  }

  onChangePassword(String? val) {
    _password = val!;
  }

  onChangeRePassword(String? val) {
    _rePassword = val!;
  }

  String? passwordValidator(String? val) {
    if (val == null || val.isEmpty) {
      return "Please enter password";
    } else if (val.length < MIN_PASSWORD_LENGTH) {
      return "Too short password";
    }
    return null;
  }

  String? nameValidator(String? val) {
    if (val == null || val.isEmpty) {
      return "Please enter valid name";
    } else if (val.length < 2) {
      return "Too short characters";
    }
    return null;
  }

  String? emailValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter valid phone";
    }
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return "$value is invalid email";
    }
    return null;
  }

  void onSignUp() async {
    setBusy(true);
    setError(null);
    if (_password.isNotEmpty && _password != _rePassword) {
      setError("Password mismatched.");
      rebuildUi();
      setBusy(false);
      return;
    }
    try {
      if (formKey.currentState!.validate()) {
        String? deviceId = await FirebaseMessaging.instance.getToken();
        var res = await _authService.createAccount(
            UserAccount(
              firstName: _firstName,
              email: _email,
              deviceId: deviceId,
            ),
            _password);
        if (!res.isSuccessful) {
          setError("Got something wrong on registring your account...");
        }
      }
    } catch (e) {
      setError("Got unhandled error, please try again.");
    } finally {
      setBusy(false);
    }
  }

  Future<bool> onWillPopScope() async {
    SystemNavigator.pop();
    return true;
  }
}
