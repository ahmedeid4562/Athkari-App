import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/daily_progress_service.dart';
import '../../data/api/azkar_local_data.dart';
import '../../data/model/azkar_model.dart';

class AzkarDetailsState {
  final bool isLoading;
  final List<AzkarModel> azkar;
  final int currentIndex;
  final int remaining;
  final int completedToday;
  final String? error;

  const AzkarDetailsState({
    this.isLoading = false,
    this.azkar = const [],
    this.currentIndex = 0,
    this.remaining = 0,
    this.completedToday = 0,
    this.error,
  });

  bool get isCompleted => azkar.isNotEmpty && currentIndex >= azkar.length;

  AzkarModel? get currentAzkar => isCompleted ? null : azkar[currentIndex];

  int get completedCount => currentIndex;
}

class AzkarDetailsCubit extends Cubit<AzkarDetailsState> {
  final AzkarLocalData _localData;
  final DailyProgressService _progressService = DailyProgressService();

  String? _categoryId;

  AzkarDetailsCubit(this._localData) : super(const AzkarDetailsState());

  Future<void> loadAzkar(String categoryId) async {
    _categoryId = categoryId;

    emit(const AzkarDetailsState(isLoading: true));

    try {
      final azkar = await _localData.getAzkar(categoryId);
      final completedToday = await _progressService.getCompletedCount();

      emit(
        AzkarDetailsState(
          azkar: azkar,
          remaining: azkar.isEmpty ? 0 : azkar.first.repeat,
          completedToday: completedToday,
        ),
      );
    } catch (_) {
      emit(const AzkarDetailsState(error: 'حدث خطأ أثناء تحميل الأذكار'));
    }
  }

  Future<void> decrement() async {
    if (state.isCompleted || state.remaining <= 0) return;

    if (state.remaining == 1) {
      final currentAzkar = state.currentAzkar;
      final categoryId = _categoryId;

      if (currentAzkar != null && categoryId != null) {
        await _progressService.markCompleted(
          categoryId: categoryId,
          zekrId: currentAzkar.id,
        );
      }

      final completedToday = await _progressService.getCompletedCount();

      final nextIndex = state.currentIndex + 1;

      emit(
        AzkarDetailsState(
          azkar: state.azkar,
          currentIndex: nextIndex,
          remaining: nextIndex < state.azkar.length
              ? state.azkar[nextIndex].repeat
              : 0,
          completedToday: completedToday,
        ),
      );

      return;
    }

    emit(
      AzkarDetailsState(
        azkar: state.azkar,
        currentIndex: state.currentIndex,
        remaining: state.remaining - 1,
        completedToday: state.completedToday,
      ),
    );
  }

  void nextAzkar() {
    if (state.isCompleted || state.remaining > 0) return;

    final nextIndex = state.currentIndex + 1;

    emit(
      AzkarDetailsState(
        azkar: state.azkar,
        currentIndex: nextIndex,
        remaining: nextIndex < state.azkar.length
            ? state.azkar[nextIndex].repeat
            : 0,
        completedToday: state.completedToday,
      ),
    );
  }

  void resetCounter() {
    if (state.currentAzkar == null) return;

    emit(
      AzkarDetailsState(
        azkar: state.azkar,
        currentIndex: state.currentIndex,
        remaining: state.currentAzkar!.repeat,
        completedToday: state.completedToday,
      ),
    );
  }
}
