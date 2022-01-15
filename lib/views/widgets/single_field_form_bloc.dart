import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

typedef SingleFieldValidate<T> = String? Function(T?)?;
typedef SingleFieldOnSave<T> = Future<void> Function(T);

class SingleFieldFormState<T> extends Equatable {
  final T value;
  final String? validationError;
  final bool buttonEnabled;
  final bool editMode;
  final T? confirmation;

  const SingleFieldFormState({
    required this.value,
    this.validationError,
    required this.buttonEnabled,
    this.editMode = true,
    required this.confirmation,
  });

  bool get confirmed => value == confirmation;

  @override
  List<Object?> get props => [
        value,
        validationError,
        buttonEnabled,
        editMode,
        confirmation,
      ];
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

class SingleFieldFormConfirmed<T> extends SingleFieldFormEvent<T> {
  final T confirmation;

  SingleFieldFormConfirmed(this.confirmation);
}

class SingleFieldFormSave<T> extends SingleFieldFormEvent<T> {
  final SingleFieldOnSave<T> onSave;
  final VoidCallback onSaveError;
  SingleFieldFormSave(
    this.onSave,
    this.onSaveError,
  );
}

class SingleFieldFormReset<T> extends SingleFieldFormEvent<T> {}

class SingleFieldFormConfirmationReset<T> extends SingleFieldFormEvent<T> {}

class SingleFieldFormSetEditMode<T> extends SingleFieldFormEvent<T> {
  SingleFieldFormSetEditMode();
}

class SingleFieldFormBloc<T>
    extends Bloc<SingleFieldFormEvent<T>, SingleFieldFormState<T>> {
  final T initialValue;
  final bool withEditMode;
  final bool withConfirmation;

  SingleFieldFormBloc(
    this.initialValue, {
    this.withEditMode = false,
    this.withConfirmation = false,
  }) : super(
          SingleFieldFormState<T>(
            value: initialValue,
            buttonEnabled: false,
            editMode: !withEditMode,
            confirmation: null,
          ),
        ) {
    on<SingleFieldFormChanged<T>>(onSingleFieldFormChanged);
    on<SingleFieldFormSave<T>>(onSingleFieldFormSave);
    on<SingleFieldFormReset<T>>(onSingleFieldFormReset);
    on<SingleFieldFormSetEditMode<T>>(onSingleFieldFormSetEditMode);
    on<SingleFieldFormConfirmed<T>>(onSingleFieldFormConfirmed);
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
        buttonEnabled: isButtonEnabled(
          event.value,
          state.confirmation,
          validationError,
        ),
        confirmation: state.confirmation,
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
            confirmation: state.confirmation,
          ),
        );
        await event.onSave(state.value);
      } catch (e, s) {
        debugPrint('Error on SingleFieldFormSave: $e\n$s');
        emit(
          SingleFieldFormState<T>(
            value: state.value,
            buttonEnabled: state.value != initialValue,
            confirmation: state.confirmation,
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
        confirmation: state.confirmation,
      ),
    );
  }

  void onSingleFieldFormSetEditMode(SingleFieldFormSetEditMode<T> event, emit) {
    emit(
      SingleFieldFormState<T>(
        value: initialValue,
        buttonEnabled: false,
        editMode: true,
        confirmation: null,
      ),
    );
  }

  void onSingleFieldFormConfirmed(SingleFieldFormConfirmed<T> event, emit) {
    emit(
      SingleFieldFormState<T>(
        value: state.value,
        buttonEnabled: isButtonEnabled(
          state.value,
          event.confirmation,
          state.validationError,
        ),
        editMode: state.editMode,
        confirmation: event.confirmation,
      ),
    );
  }

  bool isButtonEnabled(T value, T? confirmation, String? validationError) =>
      value != initialValue &&
      validationError == null &&
      (!withConfirmation || state.confirmed);
}
