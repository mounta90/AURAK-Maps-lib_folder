// This file includes all classes that deal with errors in the login and registration pages.

// Login Exceptions

class UserNotFoundAuthException implements Exception {}

class WrongPasswordAuthException implements Exception {}

class OperationNotAllowedAuthException implements Exception {}

// Other General Exceptions

class GenericAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}
