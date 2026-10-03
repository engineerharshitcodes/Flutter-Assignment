import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<int> _favorites = {};

  Set<int> get favorites => _favorites;

  bool isFavorite(int id) {
    return _favorites.contains(id);
  }

  Future<void> toggleFavorite(int id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'favorites',
      _favorites.map((id) => id.toString()).toList(),
    );
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList('favorites') ?? [];

    _favorites
      ..clear()
      ..addAll(saved.map((id) => int.parse(id)));

    notifyListeners();
  }
}
