import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/api/quran_local_data.dart';
import '../../data/model/quran_surah_model.dart';

class QuranState {
  final bool isLoading;
  final List<QuranSurahModel> surahs;
  final String? error;

  const QuranState({
    this.isLoading = false,
    this.surahs = const [],
    this.error,
  });
}

class QuranCubit extends Cubit<QuranState> {
  final QuranLocalData _quranLocalData;

  QuranCubit(this._quranLocalData) : super(const QuranState());

  Future<void> loadSurahs() async {
    emit(const QuranState(isLoading: true));

    try {
      final surahs = await _quranLocalData.loadSurahs();

      emit(QuranState(surahs: surahs));
    } catch (e) {
      emit(QuranState(error: e.toString()));
    }
  }
}
