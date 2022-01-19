import 'package:bloc/bloc.dart';

class VersionCubit extends Cubit<String> {
  static const initialValue = 'unknown';

  VersionCubit() : super(initialValue);

  void set(String? text) => emit(text ?? initialValue);
}

class UrlCubit extends Cubit<String> {
  static const initialValue = 'unknown';

  UrlCubit() : super(initialValue);

  void set(String? text) => emit(text ?? initialValue);
}

class PolicyCubit extends Cubit<String> {
  static const initialValue = '';

  PolicyCubit() : super(initialValue);

  void set(String? text) => emit(text ?? initialValue);
}
