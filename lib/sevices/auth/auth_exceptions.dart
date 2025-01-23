//login exceptions
class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

class InvlalidCredentialsAuthException implements Exception {}

//register exceptions
class WeakPasswordAuthException implements Exception {}

class InvalidEmailAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

//both login and register or generic  exceptions
class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
