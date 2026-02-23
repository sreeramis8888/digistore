class GlobalVariables {
  static String? _userId;
  static String? _userName;
  static String? _userStatus;

  /// Initialize global variables from secure storage
  static Future<void> initialize({
    required Future<String?> Function() getUserId,
    required Future<String?> Function() getUserName,
    required Future<String?> Function() getUserStatus,
  }) async {
    try {
      _userId = await getUserId();
      _userName = await getUserName();
      _userStatus = await getUserStatus();
    } catch (e) {
      // Reset to null on error
      _userId = null;
      _userName = null;
      _userStatus = null;
    }
  }

  /// Set user ID
  static void setUserId(String? userId) {
    _userId = userId;
    if (userId != null && userId.isNotEmpty) {
      _isGuest = false;
    }
  }

  /// Get user ID (synchronous)
  static String? getUserId() {
    return _userId;
  }

  /// Set user name
  static void setUserName(String? userName) {
    _userName = userName;
  }

  /// Get user name (synchronous)
  static String? getUserName() {
    return _userName;
  }

  /// Set user status
  static void setUserStatus(String? userStatus) {
    _userStatus = userStatus;
  }

  /// Get user status (synchronous)
  static String? getUserStatus() {
    return _userStatus;
  }

  /// Clear all global variables (useful for logout)
  static void clear() {
    _userId = null;
    _userName = null;
    _userStatus = null;
  }

  static String preferredLanguage = 'en';

  static void setPreferredLanguage(String language) {
    preferredLanguage = language;
  }

  static String getPreferredLanguage() {
    return preferredLanguage;
  }

  /// Check if user data is loaded
  static bool isInitialized() {
    return _userId != null;
  }

  static bool _isGuest = false;

  static void setGuestMode(bool value) {
    _isGuest = value;
    if (value) {
      _userId = null;
      _userName = null;
      _userStatus = null;
    }
  }

  static bool get isGuest => _isGuest && _userId == null;

  static void resetGuestMode() {
    _isGuest = false;
  }
}
