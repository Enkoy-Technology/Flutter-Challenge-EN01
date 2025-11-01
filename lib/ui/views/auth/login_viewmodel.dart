// ignore_for_file: use_build_context_synchronously

import 'package:enkoy_chat/app/app.locator.dart';
import 'package:enkoy_chat/app/app.router.dart';
import 'package:enkoy_chat/interfaces/iauth.interface.dart';
import 'package:enkoy_chat/ui/common/app_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class LoginViewModel extends BaseViewModel {
  final BuildContext context;

  LoginViewModel({required this.context});

  String _email = "";
  String _password = "";
  bool _showPassword = false;
  bool _remeberMe = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final _authService = locator<IAuthService>();
  final _navigationService = locator<NavigationService>();

  bool get showPassword => _showPassword;

  bool get remeberMe => _remeberMe;

  // String? get savedEmail => _appSettingProvider.savedUserPhoneNumber;

  bool isNormalLoginProcessing = false;
  bool isGoogleLoginProcessing = false;

  toggleShowPassword() {
    _showPassword = !_showPassword;
    rebuildUi();
  }

  onChangeEmail(String? val) {
    _email = val!;
  }

  onChangePassword(String? val) {
    _password = val!;
  }

  onLogin() async {
    if (formKey.currentState!.validate()) {
      isNormalLoginProcessing = true;
      rebuildUi();
      setError(null);
      try {
        var resData =
            await _authService.loginWithEmailAndPassword(_email, _password);

        ////
        ///Successful login will be handled by auth listener in startup viewmodel
        ///
        if (!resData.isSuccessful) {
          setError(resData.errorMessages.join("\n"));
        }
      } catch (e) {
        setError("Got unhandled error.");
      } finally {
        isNormalLoginProcessing = false;
        rebuildUi();
      }
    }
  }

  onLoginWithGoogle() async {
    isGoogleLoginProcessing = true;
    rebuildUi();
    setError(null);
    try {
      var res = await _authService.loginWithGoogle();
      if (!res.isSuccessful) {
        setError(res.errorMessages.join('\n'));
      }
    } catch (e) {
      setError("Got unhandled error.");
    } finally {
      isGoogleLoginProcessing = false;
      rebuildUi();
    }
  }

  String? passwordValidator(String? val) {
    if (val == null || val.isEmpty) {
      return "Please enter password";
    } else if (val.length < MIN_PASSWORD_LENGTH) {
      return "Too short password";
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

  void onRemberMeChanged(bool? value) {
    _remeberMe = value!;
    rebuildUi();
  }

  void onForgetPassword() {}

  void onCreateAccountTapped() {
    _navigationService.navigateToSignupView();
  }

  Future<bool> onWillPopScope() async {
    SystemNavigator.pop();
    return true;
  }
}
