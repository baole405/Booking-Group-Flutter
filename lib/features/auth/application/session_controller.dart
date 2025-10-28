import 'package:booking_group_flutter/core/network/api_exception.dart';
import 'package:booking_group_flutter/core/storage/session_storage.dart';
import 'package:booking_group_flutter/features/auth/data/auth_repository.dart';
import 'package:booking_group_flutter/features/user/data/user_repository.dart';
import 'package:booking_group_flutter/features/user/domain/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum SessionStatus { loading, authenticated, unauthenticated, error }

class SessionController extends ChangeNotifier {
  SessionController({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required SessionStorage storage,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        _storage = storage;

  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final SessionStorage _storage;

  SessionStatus status = SessionStatus.loading;
  UserProfile? currentUser;
  String? _errorMessage;

  String? get errorMessage => _errorMessage;
  bool get hasGroup => currentUser?.group != null;
  int? get currentGroupId => currentUser?.group?.id;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId:
        '148956304557-vimujk9msu533g182jco2bvact3g8hkg.apps.googleusercontent.com',
    forceCodeForRefreshToken: true,
  );

  Future<void> initialize() async {
    status = SessionStatus.loading;
    notifyListeners();
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final storedToken = await _storage.readToken();
      if (firebaseUser != null && storedToken != null && storedToken.isNotEmpty) {
        await _loadProfile();
        status = SessionStatus.authenticated;
      } else {
        await _signOutSilently();
        _errorMessage = null;
        status = SessionStatus.unauthenticated;
      }
    } on ApiException catch (error) {
      _errorMessage = error.message;
      status = SessionStatus.error;
    } catch (error) {
      _errorMessage = error.toString();
      status = SessionStatus.error;
    }
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    status = SessionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        status = SessionStatus.unauthenticated;
        notifyListeners();
        return;
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;
      if (idToken == null) {
        throw const ApiException('Missing Google ID token');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: idToken,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);

      final session = await _authRepository.loginWithGoogle(idToken);
      await _storage.saveSession(token: session.token, email: session.email);

      await _loadProfile();
      status = SessionStatus.authenticated;
    } on FirebaseAuthException catch (error) {
      _errorMessage = error.message ?? 'Firebase authentication failed';
      status = SessionStatus.error;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      status = SessionStatus.error;
    } catch (error) {
      _errorMessage = error.toString();
      status = SessionStatus.error;
    }
    notifyListeners();
  }

  Future<void> reloadProfile() async {
    if (status != SessionStatus.authenticated) return;
    try {
      await _loadProfile();
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Failed to reload profile: $error');
      }
    }
  }

  Future<void> signOut() async {
    status = SessionStatus.loading;
    notifyListeners();
    await _signOutSilently();
    _errorMessage = null;
    status = SessionStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _loadProfile() async {
    currentUser = await _userRepository.fetchMyProfile();
  }

  Future<void> _signOutSilently() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    await _storage.clear();
    currentUser = null;
    _errorMessage = null;
  }
}
