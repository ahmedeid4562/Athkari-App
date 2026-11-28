import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/api/quran_partition_local_data.dart';
import '../../data/model/quran_partition_model.dart';

class QuranPartitionState {
  final bool isLoading;
  final List<QuranPartitionModel> juzs;
  final List<QuranPartitionModel> hizbs;
  final List<QuranPartitionModel> pages;
  final String? error;

  const QuranPartitionState({
    this.isLoading = false,
    this.juzs = const [],
    this.hizbs = const [],
    this.pages = const [],
    this.error,
  });
}

class QuranPartitionCubit extends Cubit<QuranPartitionState> {
  final QuranPartitionLocalData _localData;

  QuranPartitionCubit(this._localData) : super(const QuranPartitionState());

  Future<void> loadPartitions() async {
    emit(const QuranPartitionState(isLoading: true));

    try {
      final juzs = await _localData.loadJuzs();
      final quarters = await _localData.loadQuarters();
      final pages = await _localData.loadPages();

      final hizbs = quarters
          .where((quarter) => (quarter.index - 1) % 4 == 0)
          .toList();

      emit(QuranPartitionState(juzs: juzs, hizbs: hizbs, pages: pages));
    } catch (e) {
      emit(QuranPartitionState(error: e.toString()));
    }
  }
}
