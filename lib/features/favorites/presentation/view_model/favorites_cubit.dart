import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../azkar/data/model/azkar_model.dart';
import '../../data/api/favorites_local_data.dart';

class FavoritesState {
  final bool isLoading;
  final List<AzkarModel> favorites;
  final String? error;

  const FavoritesState({
    this.isLoading = false,
    this.favorites = const [],
    this.error,
  });

  FavoritesState copyWith({
    bool? isLoading,
    List<AzkarModel>? favorites,
    String? error,
  }) {
    return FavoritesState(
      isLoading: isLoading ?? this.isLoading,
      favorites: favorites ?? this.favorites,
      error: error,
    );
  }
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesLocalData _localData;

  FavoritesCubit(this._localData) : super(const FavoritesState());

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final favorites = await _localData.getFavorites();

      emit(
        state.copyWith(
          isLoading: false,
          favorites: favorites,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'حدث خطأ أثناء تحميل المفضلة',
        ),
      );
    }
  }

  Future<void> addFavorite(AzkarModel azkar) async {
    await _localData.addFavorite(azkar);
    await loadFavorites();
  }

  Future<void> removeFavorite(AzkarModel azkar) async {
    await _localData.removeFavorite(azkar);
    await loadFavorites();
  }

  bool isFavorite(AzkarModel azkar) {
    return state.favorites.any(
      (item) =>
          item.text == azkar.text &&
          item.reference == azkar.reference,
    );
  }

  Future<void> toggleFavorite(AzkarModel azkar) async {
    if (isFavorite(azkar)) {
      await removeFavorite(azkar);
    } else {
      await addFavorite(azkar);
    }
  }
}
