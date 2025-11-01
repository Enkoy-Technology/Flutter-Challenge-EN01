import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';
import '../../../../core/config/app_constants.dart';
import '../models/user_model.dart';

class AuthRemoteSource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Logger _logger = Logger('AuthRemoteSource');

  Future<UserModel> register(String email, String password, String name) async {
    try {
      _logger.info('Starting registration process for email: $email');

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _logger.info(
        'User created successfully with UID: ${credential.user!.uid}',
      );

      final user = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: name,
      );

      _logger.info('Storing user data in Firestore for UID: ${user.uid}');

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(user.toMap());

      _logger.info('User data stored successfully in Firestore');

      return user;
    } on FirebaseAuthException catch (e) {
      _logger.severe('Firebase Auth Exception during registration', e);

      if (e.code == 'email-already-in-use') {
        _logger.warning('Registration failed: Email $email is already in use');
        throw Exception(
          'The email address is already in use by another account.',
        );
      } else if (e.code == 'weak-password') {
        _logger.warning('Registration failed: Weak password provided');
        throw Exception('The password provided is too weak.');
      } else if (e.code == 'invalid-email') {
        _logger.warning('Registration failed: Invalid email format - $email');
        throw Exception('The email address is not valid.');
      } else {
        _logger.severe(
          'Unknown Firebase Auth error during registration: ${e.code}',
        );
        throw Exception('Registration failed: ${e.message}');
      }
    } on FirebaseException catch (e) {
      _logger.severe('Firestore Exception during registration', e);
      throw Exception('Failed to store user data: ${e.message}');
    } on Exception catch (e) {
      _logger.severe('Unexpected exception during registration', e);
      throw Exception('Registration failed due to an unexpected error.');
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      _logger.info('Starting login process for email: $email');

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _logger.info(
        'User authenticated successfully with UID: ${credential.user!.uid}',
      );
      _logger.info('Fetching user data from Firestore');

      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(credential.user!.uid)
          .get();

      if (!snapshot.exists) {
        _logger.warning(
          'User document not found in Firestore for UID: ${credential.user!.uid}',
        );
        throw Exception('User data not found. Please contact support.');
      }

      _logger.info('User data retrieved successfully from Firestore');

      return UserModel.fromMap(snapshot.data()!);
    } on FirebaseAuthException catch (e) {
      _logger.severe('Firebase Auth Exception during login', e);

      if (e.code == 'user-not-found') {
        _logger.warning('Login failed: No user found for email: $email');
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        _logger.warning(
          'Login failed: Wrong password provided for email: $email',
        );
        throw Exception('Wrong password provided for that user.');
      } else if (e.code == 'invalid-email') {
        _logger.warning('Login failed: Invalid email format - $email');
        throw Exception('The email address is not valid.');
      } else if (e.code == 'user-disabled') {
        _logger.warning(
          'Login failed: User account disabled for email: $email',
        );
        throw Exception('This user account has been disabled.');
      } else {
        _logger.severe('Unknown Firebase Auth error during login: ${e.code}');
        throw Exception('Login failed: ${e.message}');
      }
    } on FirebaseException catch (e) {
      _logger.severe('Firestore Exception during login', e);
      throw Exception('Failed to retrieve user data: ${e.message}');
    } on Exception catch (e) {
      _logger.severe('Unexpected exception during login', e);
      throw Exception('Login failed due to an unexpected error.');
    }
  }

  Stream<User?> get authStateChanges {
    _logger.fine('Accessing auth state changes stream');
    return _auth.authStateChanges();
  }

  Future<void> logout() async {
    try {
      _logger.info('Starting logout process');

      await _auth.signOut();

      _logger.info('User logged out successfully');
    } on FirebaseAuthException catch (e) {
      _logger.severe('Firebase Auth Exception during logout', e);
      throw Exception('Logout failed: ${e.message}');
    } on Exception catch (e) {
      _logger.severe('Unexpected exception during logout', e);
      throw Exception('Logout failed due to an unexpected error.');
    }
  }
}
