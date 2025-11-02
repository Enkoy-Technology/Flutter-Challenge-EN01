import 'package:enkoy_chat/ui/common/app_strings.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:enkoy_chat/ui/common/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StartupViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            kdSpaceLarge.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(kiFlash, size: kfIconNormal),
                kdSpaceTiny.width,
                Text(
                  ksAppName,
                  style: GoogleFonts.syne(
                      fontWeight: FontWeight.bold, fontSize: kfXLarge),
                ),
              ],
            ),
            Text(
              ksAppMoto,
              style: kfLabelSmall(context),
            ),
            kdSpaceLarge.height,
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [LoadingIndicator()],
            ),
          ],
        ),
      ),
    );
  }

  @override
  StartupViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) => SchedulerBinding.instance
      .addPostFrameCallback((timeStamp) => viewModel.setUp());
}
