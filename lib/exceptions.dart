class LandCreationException implements Exception {
  final Object? message;

  LandCreationException({this.message});

  @override
  String toString() {
    if (message != null) {
      return "Land creation failed: ${Error.safeToString(message)}";
    }
    return "Land creation failed";
  }
}

class GPSException implements Exception {
  final Object? message;

  GPSException({this.message});

  @override
  String toString() {
    if (message != null) {
      return "Location services failed: ${Error.safeToString(message)}";
    }
    return "Location services failed";
  }
}

class RegisterException implements Exception {
  /// Message describing the assertion error.
  final Object? message;

  RegisterException(this.message);

  @override
  String toString() {
    if (message != null) {
      return "Registration failed: ${Error.safeToString(message)}";
    }
    return "Registration failed";
  }
}

class LoginException implements Exception {
  /// Message describing the assertion error.
  final Object? message;

  LoginException(this.message);

  @override
  String toString() {
    if (message != null) {
      return "Login failed: ${Error.safeToString(message)}";
    }
    return "Login failed";
  }
}
