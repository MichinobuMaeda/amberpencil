import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

typedef SingleFieldValidate<T> = String? Function(T?)?;
typedef SingleFieldOnValueReset<T> = void Function(T);
typedef SingleFieldOnSave<T> = Future<void> Function(T);

class SingleFieldFormState<T> {
  final T value;
  final String? validationError;
  final bool buttonEnabled;
  final bool editMode;

  const SingleFieldFormState({
    required this.value,
    this.validationError,
    required this.buttonEnabled,
    this.editMode = true,
  });
}

abstract class SingleFieldFormEvent<T> {}

class SingleFieldFormChanged<T> extends SingleFieldFormEvent<T> {
  final T value;
  final SingleFieldValidate<T>? validator;
  final VoidCallback? onValueChange;

  SingleFieldFormChanged(
    this.value, {
    this.validator,
    this.onValueChange,
  });
}

class SingleFieldFormSave<T> extends SingleFieldFormEvent<T> {
  final SingleFieldOnSave<T> onSave;
  final VoidCallback onSaveError;
  SingleFieldFormSave(
    this.onSave,
    this.onSaveError,
  );
}

class SingleFieldFormReset<T> extends SingleFieldFormEvent<T> {
  final VoidCallback onValueReset;
  SingleFieldFormReset(
    this.onValueReset,
  );
}

class SingleFieldFormSetEditMode<T> extends SingleFieldFormEvent<T> {
  SingleFieldFormSetEditMode();
}

class SingleFieldFormBloc<T>
    extends Bloc<SingleFieldFormEvent<T>, SingleFieldFormState<T>> {
  final T initialValue;
  final bool withEditMode;

  SingleFieldFormBloc(
    this.initialValue, {
    this.withEditMode = false,
  }) : super(
          SingleFieldFormState<T>(
            value: initialValue,
            buttonEnabled: false,
            editMode: !withEditMode,
          ),
        ) {
    on<SingleFieldFormChanged<T>>(onSingleFieldFormChanged);
    on<SingleFieldFormSave<T>>(onSingleFieldFormSave);
    on<SingleFieldFormReset<T>>(onSingleFieldFormReset);
    on<SingleFieldFormSetEditMode<T>>(onSingleFieldFormSetEditMode);
  }

  void onSingleFieldFormChanged(SingleFieldFormChanged<T> event, emit) {
    final String? validationError =
        (event.value == initialValue || event.validator == null)
            ? null
            : event.validator!(event.value);
    emit(
      SingleFieldFormState<T>(
        value: event.value,
        validationError: validationError,
        buttonEnabled: event.value != initialValue && validationError == null,
      ),
    );
    if (event.onValueChange != null) event.onValueChange!();
  }

  void onSingleFieldFormSave(SingleFieldFormSave<T> event, emit) async {
    if (state.value != initialValue) {
      try {
        emit(
          SingleFieldFormState<T>(
            value: state.value,
            buttonEnabled: false,
          ),
        );
        await event.onSave(state.value);
      } catch (e, s) {
        debugPrint('Error on SingleFieldFormSave: $e\n$s');
        emit(
          SingleFieldFormState<T>(
            value: state.value,
            buttonEnabled: state.value != initialValue,
          ),
        );
        event.onSaveError();
      }
    }
  }

  void onSingleFieldFormReset(SingleFieldFormReset<T> event, emit) async {
    emit(
      SingleFieldFormState<T>(
        value: initialValue,
        buttonEnabled: false,
        editMode: !withEditMode,
      ),
    );
    event.onValueReset();
  }

  void onSingleFieldFormSetEditMode(SingleFieldFormSetEditMode<T> event, emit) {
    emit(
      SingleFieldFormState<T>(
        value: initialValue,
        buttonEnabled: false,
        editMode: true,
      ),
    );
  }
}
