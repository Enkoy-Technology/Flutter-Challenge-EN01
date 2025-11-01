import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:enkoy_chat/ui/common/widgets/app_bar_widget.dart';
import 'package:enkoy_chat/ui/common/widgets/auth_button.dart';
import 'package:enkoy_chat/ui/common/widgets/error_message_widget.dart';
import 'package:enkoy_chat/ui/common/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'signup_viewmodel.dart';

class SignupView extends StackedView<SignupViewModel> {
  const SignupView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SignupViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          const AppBarWidget(title: "Create account"),
          SliverFillRemaining(
            child: Padding(
              padding: const EdgeInsets.all(kdPadding),
              child: Form(
                key: viewModel.formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFieldWidget(
                          // initialValue: viewModel.savedPhoneNumber,
                          textInputType: TextInputType.emailAddress,
                          onChanged: viewModel.onChangeFirstName,
                          validator: viewModel.nameValidator,
                          prefixIcon: kiName,
                          hintText: "First name"),
                      kdSpaceLarge.height,
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
                        obscureText: !viewModel.showPasswordOne,
                        hintText: "Password",
                        suffixWidget: IconButton(
                          icon: Icon(
                              !viewModel.showPasswordOne ? kiEyeOff : kiEye),
                          onPressed: viewModel.toggleShowPasswordOne,
                        ),
                      ),
                      kdSpaceLarge.height,
                      TextFieldWidget(
                        onChanged: viewModel.onChangeRePassword,
                        validator: viewModel.passwordValidator,
                        prefixIcon: kiPassword,
                        obscureText: !viewModel.showPasswordTwo,
                        hintText: "Retype password",
                        suffixWidget: IconButton(
                          icon: Icon(
                              !viewModel.showPasswordTwo ? kiEyeOff : kiEye),
                          onPressed: viewModel.toggleShowPasswordTwo,
                        ),
                      ),
                      kdSpaceLarge.height,
                      if (viewModel.hasError) ...[
                        ErrorMessageWidget(message: viewModel.modelError),
                        kdSpaceXLarge.height
                      ],
                      kdSpaceXLarge.height,
                      SizedBox(
                        width: kdScreenWidth(context),
                        child: AuthButton(
                          onPressed: viewModel.onSignUp,
                          title: 'Create Account',
                          isBusy: viewModel.isBusy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  SignupViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SignupViewModel();
}
