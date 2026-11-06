import 'package:flutter/foundation.dart';

enum SavedPlaceKind { home, work, custom }

class SavedLocation {
  const SavedLocation({
    required this.id,
    required this.label,
    required this.address,
    this.distanceLabel = '0.08KM',
    this.kind = SavedPlaceKind.custom,
  });

  final String id;
  final String label;
  final String address;
  final String distanceLabel;
  final SavedPlaceKind kind;
}

/// Preferences shared by the app's tabs for the current session.
class UserProfileStore extends ChangeNotifier {
  String _name = 'Pejuang Pangan';
  String _phone = '81274183515';
  String _email = 'pejuang@bagiporsi.id';
  String? _gender;
  String? _location;
  String? _activeLocationId;
  int _nextId = 1;
  bool _notificationsEnabled = true;
  final _favorites = <String>{};
  final _savedLocations = <SavedLocation>[];

  String get name => _name;
  String get phone => _phone;
  String get email => _email;
  String? get gender => _gender;
  String? get location => _location;
  String? get activeLocationId => _activeLocationId;
  bool get notificationsEnabled => _notificationsEnabled;
  Set<String> get favorites => Set.unmodifiable(_favorites);
  List<SavedLocation> get savedLocations => List.unmodifiable(_savedLocations);

  SavedLocation? get homeLocation {
    for (final item in _savedLocations) {
      if (item.kind == SavedPlaceKind.home) return item;
    }
    return null;
  }

  SavedLocation? get workLocation {
    for (final item in _savedLocations) {
      if (item.kind == SavedPlaceKind.work) return item;
    }
    return null;
  }

  List<SavedLocation> get customLocations => _savedLocations
      .where((item) => item.kind == SavedPlaceKind.custom)
      .toList(growable: false);

  void updateName(String name) {
    if (name.trim().isEmpty || name.trim() == _name) return;
    _name = name.trim();
    notifyListeners();
  }

  void updateProfile({
    required String name,
    String? phone,
    String? email,
    String? gender,
  }) {
    if (name.trim().isNotEmpty) _name = name.trim();
    if (phone != null && phone.trim().isNotEmpty) _phone = phone.trim();
    if (email != null && email.trim().isNotEmpty) _email = email.trim();
    _gender = gender;
    notifyListeners();
  }

  void updateLocation(String location) {
    final trimmed = location.trim();
    if (trimmed.isEmpty) return;
    if (homeLocation == null) {
      savePlace(label: 'Rumah', address: trimmed, kind: SavedPlaceKind.home);
      return;
    }
    _location = trimmed;
    notifyListeners();
  }

  SavedLocation savePlace({
    required String label,
    required String address,
    SavedPlaceKind kind = SavedPlaceKind.custom,
  }) {
    final trimmedLabel = label.trim().isEmpty ? 'Tempat Favorit' : label.trim();
    final trimmedAddress = address.trim();
    if (trimmedAddress.isEmpty) {
      throw ArgumentError('Alamat tidak boleh kosong');
    }

    if (kind == SavedPlaceKind.home || kind == SavedPlaceKind.work) {
      final existingIndex = _savedLocations.indexWhere((e) => e.kind == kind);
      final entry = SavedLocation(
        id: existingIndex >= 0
            ? _savedLocations[existingIndex].id
            : 'place-${_nextId++}',
        label: kind == SavedPlaceKind.home ? 'Rumah' : 'Tempat Kerja',
        address: trimmedAddress,
        distanceLabel: kind == SavedPlaceKind.home ? '0.08KM' : '1.20KM',
        kind: kind,
      );
      if (existingIndex >= 0) {
        _savedLocations[existingIndex] = entry;
      } else {
        _savedLocations.insert(
          kind == SavedPlaceKind.home ? 0 : (_savedLocations.isEmpty ? 0 : 1),
          entry,
        );
      }
      _activeLocationId = entry.id;
      _location = entry.address;
      notifyListeners();
      return entry;
    }

    final distances = ['0.25KM', '0.45KM', '0.80KM', '1.50KM'];
    final entry = SavedLocation(
      id: 'place-${_nextId++}',
      label: trimmedLabel,
      address: trimmedAddress,
      distanceLabel: distances[customLocations.length % distances.length],
      kind: SavedPlaceKind.custom,
    );
    _savedLocations.add(entry);
    _activeLocationId = entry.id;
    _location = entry.address;
    notifyListeners();
    return entry;
  }

  void selectLocation(String id) {
    final index = _savedLocations.indexWhere((e) => e.id == id);
    if (index < 0) return;
    final chosen = _savedLocations[index];
    _activeLocationId = chosen.id;
    _location = chosen.address;
    notifyListeners();
  }

  void removeLocation(String id) {
    final index = _savedLocations.indexWhere((e) => e.id == id);
    if (index < 0) return;
    _savedLocations.removeAt(index);
    if (_activeLocationId == id) {
      if (_savedLocations.isNotEmpty) {
        _activeLocationId = _savedLocations.first.id;
        _location = _savedLocations.first.address;
      } else {
        _activeLocationId = null;
        _location = null;
      }
    }
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
