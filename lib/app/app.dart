import 'package:enkoy_chat/interfaces/iauth.interface.dart';
import 'package:enkoy_chat/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:enkoy_chat/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:enkoy_chat/ui/views/startup/startup_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:enkoy_chat/ui/views/auth/login_view.dart';
import 'package:enkoy_chat/services/auth_service.dart';
import 'package:enkoy_chat/ui/views/chat/chat_list_view.dart';
import 'package:enkoy_chat/ui/views/chat/chat_conversation_view.dart';
import 'package:enkoy_chat/services/chat_service.dart';
import 'package:enkoy_chat/ui/views/auth/signup_view.dart';
import 'package:enkoy_chat/ui/views/chat/search_user_view.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: StartupView),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: ChatListView),
    MaterialRoute(page: ChatConversationView),
    MaterialRoute(page: SignupView),
    MaterialRoute(page: SearchUserView),
// @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton<IAuthService>(classType: FirebaseAuthService),
    LazySingleton(classType: ChatService),
// @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
