import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/api/daily_dua_local_data.dart';
import '../../data/model/daily_dua_model.dart';

class DailyDuaState {
  final bool isLoading;
  final DailyDuaModel? dua;
  final String? error;

  const DailyDuaState({this.isLoading = false, this.dua, this.error});

  DailyDuaState copyWith({bool? isLoading, DailyDuaModel? dua, String? error}) {
    return DailyDuaState(
      isLoading: isLoading ?? this.isLoading,
      dua: dua ?? this.dua,
      error: error,
    );
  }
}

class DailyDuaCubit extends Cubit<DailyDuaState> {
  final DailyDuaLocalData _localData;

  DailyDuaCubit(this._localData) : super(const DailyDuaState());

  void loadDailyDua() {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final dua = _localData.getDailyDua();

      emit(state.copyWith(isLoading: false, dua: dua));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'حدث خطأ أثناء تحميل دعاء اليوم',
        ),
      );
    }
  }

  void changeDua() {
    final currentDua = state.dua;

    if (currentDua == null) return;

    final duas = _localData.getDuas();

    final currentIndex = duas.indexWhere((item) => item.id == currentDua.id);

    final nextIndex = (currentIndex + 1) % duas.length;

    emit(state.copyWith(dua: duas[nextIndex]));
  }
}
