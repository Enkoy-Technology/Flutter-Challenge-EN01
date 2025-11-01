import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;

  const AppLifecycleManager({
    super.key,
    required this.child,
  });

  @override
  State<AppLifecycleManager> createState() => _AppLifecycleManagerState();
}

class _AppLifecycleManagerState extends State<AppLifecycleManager>
    with WidgetsBindingObserver {
  final _authRepository = AuthRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateOnlineStatus(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _updateOnlineStatus(false);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      switch (state) {
        case AppLifecycleState.resumed:
          _updateOnlineStatus(true);
          break;
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
        case AppLifecycleState.detached:
          _updateOnlineStatus(false);
          break;
        case AppLifecycleState.hidden:
          break;
      }
    }
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await _authRepository.updateUserStatus(user.uid, isOnline: isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}


