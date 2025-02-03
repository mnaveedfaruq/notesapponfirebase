import 'package:firebasenotesapp/sevices/auth/auth_exceptions.dart';
import 'package:firebasenotesapp/sevices/auth/auth_provider.dart';
import 'package:firebasenotesapp/sevices/auth/authuser.dart';
import 'package:test/test.dart';

void main() {
  group('mock Authentication', () {
    final provider = MockAuthProvider();

    test('should not be initialized to begin with', () {
      expect(provider._initialized, false);
    });

    test('cannot log out without initialization', () {
      expect(provider.logout(),
          throwsA(const TypeMatcher<NotInitializedException>()));
    });

    test('upon initialization', () async {
      await provider.initialize();
      expect(provider.initialized, true);
    });

    test('user is null upon initialization', () {
      expect(provider.currentUser, null);
    });

    test('Should be able to initialize in less than 2 seconds', () async {
      await provider.initialize();
      expect(provider.initialized, true);
    }, timeout: const Timeout(Duration(seconds: 2)));

    test('create user should delegate to login function', () {
      final bademailUser =
          provider.createUser(email: 'mnf.com', password: 'somepasssword');
      expect(bademailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>()));
    });

    test('check wrong user and password  in login by calling create user ',
        () async {
      final badpassword =
          await provider.createUser(email: 'somename.com', password: 'foobar');
      expect(badpassword,
          throwsA(const TypeMatcher<WrongPasswordAuthException>()));

      final myuser = await provider.createUser(email: 'abc', password: 'def');
      expect(provider.currentUser, myuser);
      expect(myuser.isEmailVerified, false);
    });

    test('logged in user email verification check', () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user?.isEmailVerified, true);
    });

    test('should be able to logout and login again', () async {
      await provider.logout();
      await provider.login(email: 'email', password: 'password');
      final user = provider.currentUser;
      expect(user, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _initialized = false;
  bool get initialized => _initialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!initialized) throw NotInitializedException;
    await Future.delayed(const Duration(seconds: 2));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _initialized = true;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) {
    if (!initialized) throw NotInitializedException;
    if (email == 'nmf.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false, email: '');
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!initialized) throw NotInitializedException;
    if (_user == null) throw UserNotFoundAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!initialized) throw NotInitializedException;
    final user = _user;
    if (user == null) throw UserNotFoundAuthException();
    const newUser = AuthUser(isEmailVerified: true, email: '');
    _user = newUser;
  }
}
