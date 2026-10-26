import 'package:flutter/foundation.dart';

/// Preferences shared by the app's tabs for the current session.
class UserProfileStore extends ChangeNotifier {
  String _name = 'Pejuang Pangan';
  String? _location;
  bool _notificationsEnabled = true;
  final _favorites = <String>{};

  String get name => _name;
  String? get location => _location;
  bool get notificationsEnabled => _notificationsEnabled;
  Set<String> get favorites => Set.unmodifiable(_favorites);

  void updateName(String name) {
    if (name.trim().isEmpty || name.trim() == _name) return;
    _name = name.trim();
    notifyListeners();
  }

  void updateLocation(String location) {
    if (location.trim().isEmpty || location.trim() == _location) return;
    _location = location.trim();
    notifyListeners();
  }

  void setNotifications(bool enabled) {
    if (enabled == _notificationsEnabled) return;
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  bool isFavorite(String merchant) => _favorites.contains(merchant);

  void toggleFavorite(String merchant) {
    if (!_favorites.remove(merchant)) _favorites.add(merchant);
    notifyListeners();
  }
}
