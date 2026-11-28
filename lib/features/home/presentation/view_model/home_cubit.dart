import 'package:flutter_bloc/flutter_bloc.dart';

class HomeCubit extends Cubit<String> {
  HomeCubit() : super(_getGreeting());

  static String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'صباح الخير';
    } else if (hour >= 12 && hour < 17) {
      return 'طاب يومك';
    } else {
      return 'مساء الخير';
    }
  }
}
