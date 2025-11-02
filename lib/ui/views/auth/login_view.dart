import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:enkoy_chat/ui/common/widgets/app_image.dart';
import 'package:enkoy_chat/ui/common/widgets/auth_button.dart';
import 'package:enkoy_chat/ui/common/widgets/error_message_widget.dart';
import 'package:enkoy_chat/ui/common/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'login_viewmodel.dart';

class LoginView extends StackedView<LoginViewModel> {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    LoginViewModel viewModel,
    Widget? child,
  ) {
    return PopScope(
      canPop: false,
      onPopInvoked: (st) {
        viewModel.onWillPopScope();
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(kdPaddingLarge),
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.only(
                top: (kdScreenHeight(context) * 0.18 as double),
              ),
              color: kcBackground(context),
              child: Column(
                children: [
                  Text("Welcome Back",
                      style: kfBrandStyle(context,
                          color: Theme.of(context).hintColor)),
                  kdSpaceXLarge.height,
                  Form(
                    key: viewModel.formKey,
                    child: Column(
                      children: [
                        TextFieldWidget(
                            // initialValue: viewModel.savedPhoneNumber,
                            textInputType: TextInputType.emailAddress,
                            onChanged: viewModel.onChangeEmail,
                            validator: viewModel.emailValidator,
                            prefixIcon: kiEmail,
                            hintText: "Email"),
                        kdSpaceLarge.height,
                        TextFieldWidget(
                          onChanged: viewModel.onChangePassword,
                          validator: viewModel.passwordValidator,
                          prefixIcon: kiPassword,
                          obscureText: !viewModel.showPassword,
                          hintText: "Password",
                          suffixWidget: IconButton(
                            icon: Icon(
                                !viewModel.showPassword ? kiEyeOff : kiEye),
                            onPressed: viewModel.toggleShowPassword,
                          ),
                        ),
                        kdSpace.height,
                        if (viewModel.hasError) ...[
                          ErrorMessageWidget(message: viewModel.modelError),
                          kdSpaceXLarge.height
                        ],
                        kdSpaceXLarge.height,
                        SizedBox(
                          width: kdScreenWidth(context),
                          child: AuthButton(
                            onPressed: viewModel.onLogin,
                            title: 'Sign In',
                            isBusy: viewModel.isNormalLoginProcessing,
                          ),
                        ),
                        kdSpace.height,
                        SizedBox(
                          width: kdScreenWidth(context),
                          child: AuthButton(
                            outlineMode: true,
                            onPressed: viewModel.onLoginWithGoogle,
                            titleWidget: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AppImageWidget(
                                  url: "assets/images/icon_google.png",
                                  width: kdSmallSquareAvatar,
                                  height: kdSmallSquareAvatar,
                                  isFromLocalAsset: true,
                                ),
                                kdSpaceTiny.width,
                                const Text("Sign In with Google")
                              ],
                            ),
                            isBusy: viewModel.isGoogleLoginProcessing,
                          ),
                        ),
                        kdSpaceLarge.height,
                        Align(
                          alignment: Alignment.bottomRight,
                          child: TextButton(
                            onPressed: viewModel.onCreateAccountTapped,
                            child: Text("Create new account",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    decorationColor: kcPrimary(context),
                                    color: kcPrimary(context))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  LoginViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      LoginViewModel(context: context);
}
