import 'package:enkoy_chat/ui/common/app_colors.dart';
import 'package:enkoy_chat/ui/common/dimension.dart';
import 'package:enkoy_chat/ui/common/font.dart';
import 'package:enkoy_chat/ui/common/icons.dart';
import 'package:enkoy_chat/ui/common/utils/avatar_utils.dart';
import 'package:enkoy_chat/ui/common/utils/datetime_utils.dart';
import 'package:enkoy_chat/ui/common/widgets/app_bar_widget.dart';
import 'package:enkoy_chat/ui/common/widgets/loading_indicator.dart';
import 'package:enkoy_chat/ui/common/widgets/text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:stacked/stacked.dart';

import 'search_user_viewmodel.dart';

class SearchUserView extends StackedView<SearchUserViewModel> {
  const SearchUserView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SearchUserViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: kcBackground(context).withOpacity(0.95),
      body: viewModel.isBusy
          ? const Center(
              child: LoadingIndicator(),
            )
          : CustomScrollView(
              slivers: [
                AppBarWidget(
                  leading: GestureDetector(
                    onTap: viewModel.onBack,
                    child: Icon(
                      kiArrowBack,
                      color: kcOnPrimary(context),
                    ),
                  ),
                  titleWidget: SizedBox(
                    height: 50,
                    width: kdScreenWidth(context) * .8,
                    child: TextFieldWidget(
                      onlyUnderlineBorder: true,
                      borderRadius: 2,
                      hintText: "Type user email...",
                      hintStyle:
                          kfBodyMedium(context, color: kcOnPrimary(context)),
                      onChanged: viewModel.onSearchValChanged,
                      suffixWidget: Visibility(
                        visible: viewModel.busy(viewModel.searchResults),
                        child: SizedBox(
                          height: kdSmallSquareAvatar,
                          width: kdSmallSquareAvatar,
                          child: SpinKitHourGlass(
                            size: kdSmallSquareAvatar,
                            color: kcPrimary(context),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: viewModel.searchResults.length,
                      itemBuilder: (ctx, index) {
                        return GestureDetector(
                          onTap: () {
                            viewModel.onTapUser(viewModel.searchResults[index]);
                          },
                          child: Column(
                            children: [
                              Container(
                                color: kcBackground(context),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: kdPadding),
                                child: ListTile(
                                  horizontalTitleGap: kdSpace,
                                  leading: AvatarUtils.getAvatar(context,
                                      userAccount:
                                          viewModel.searchResults[index]),
                                  title: Text(
                                    viewModel.searchResults[index].firstName,
                                    style: kfBodyMedium(context,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        viewModel.maskEmail(
                                          viewModel.searchResults[index].email,
                                        ),
                                        style: kfBodySmall(context),
                                      ),
                                      kdSpaceSmall.height,
                                      Text(
                                        DateTimeUtils
                                            .getFormattedLastseenStatus(
                                                viewModel.searchResults[index]
                                                    .lastUpdatedAt!),
                                        style: kfBodySmall(context,
                                            color: kcLightGreyish(context)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                height: .5,
                              )
                            ],
                          ),
                        );
                      }),
                ),
              ],
            ),
    );
  }

  @override
  SearchUserViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SearchUserViewModel();
}
