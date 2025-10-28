import 'package:booking_group_flutter/app/theme/app_theme.dart';
import 'package:booking_group_flutter/core/network/backend_client.dart';
import 'package:booking_group_flutter/core/storage/session_storage.dart';
import 'package:booking_group_flutter/features/auth/application/session_controller.dart';
import 'package:booking_group_flutter/features/auth/data/auth_repository.dart';
import 'package:booking_group_flutter/features/auth/presentation/pages/login_page.dart';
import 'package:booking_group_flutter/features/groups/application/group_actions.dart';
import 'package:booking_group_flutter/features/groups/data/group_repository.dart';
import 'package:booking_group_flutter/features/shell/presentation/pages/app_shell.dart';
import 'package:booking_group_flutter/features/user/data/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingGroupApp extends StatefulWidget {
  const BookingGroupApp({super.key});

  @override
  State<BookingGroupApp> createState() => _BookingGroupAppState();
}

class _BookingGroupAppState extends State<BookingGroupApp> {
  late final SessionStorage _sessionStorage;
  late final BackendClient _backendClient;
  late final AuthRepository _authRepository;
  late final UserRepository _userRepository;
  late final GroupRepository _groupRepository;
  late final SessionController _sessionController;

  @override
  void initState() {
    super.initState();
    _sessionStorage = const SessionStorage();
    _backendClient = BackendClient(storage: _sessionStorage);
    _authRepository = AuthRepository(client: _backendClient);
    _userRepository = UserRepository(client: _backendClient);
    _groupRepository = GroupRepository(client: _backendClient);
    _sessionController = SessionController(
      authRepository: _authRepository,
      userRepository: _userRepository,
      storage: _sessionStorage,
    )..initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<BackendClient>.value(value: _backendClient),
        Provider<AuthRepository>.value(value: _authRepository),
        Provider<UserRepository>.value(value: _userRepository),
        Provider<GroupRepository>.value(value: _groupRepository),
        ChangeNotifierProvider<SessionController>.value(
          value: _sessionController,
        ),
        ProxyProvider2<GroupRepository, SessionController, GroupActions>(
          update: (_, groupRepository, session, __) => GroupActions(
            groupRepository: groupRepository,
            sessionController: session,
          ),
        ),
      ],
      child: Consumer<SessionController>(
        builder: (context, session, _) {
          return MaterialApp(
            title: 'Booking Group',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            home: _AuthGate(session: session),
          );
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate({required this.session});

  final SessionController session;

  @override
  Widget build(BuildContext context) {
    switch (session.status) {
      case SessionStatus.loading:
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      case SessionStatus.authenticated:
        return const AppShell();
      case SessionStatus.unauthenticated:
      case SessionStatus.error:
        return const LoginPage();
    }
  }
}
