import 'package:flutter_bloc/flutter_bloc.dart';

class TasbeehState {
  final int count;
  final String selectedZekr;
  final int target;

  const TasbeehState({
    this.count = 0,
    this.selectedZekr = 'سبحان الله',
    this.target = 100,
  });

  TasbeehState copyWith({
    int? count,
    String? selectedZekr,
    int? target,
  }) {
    return TasbeehState(
      count: count ?? this.count,
      selectedZekr: selectedZekr ?? this.selectedZekr,
      target: target ?? this.target,
    );
  }
}

class TasbeehCubit extends Cubit<TasbeehState> {
  TasbeehCubit() : super(const TasbeehState());

  void increment() {
    emit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    if (state.count == 0) return;

    emit(state.copyWith(count: state.count - 1));
  }

  void reset() {
    emit(state.copyWith(count: 0));
  }

  void selectZekr(String zekr) {
    emit(
      state.copyWith(
        selectedZekr: zekr,
        count: 0,
      ),
    );
  }

  void changeTarget(int target) {
    emit(state.copyWith(target: target));
  }
}