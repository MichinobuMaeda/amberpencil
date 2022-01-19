import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

typedef SingleFieldValidate<T> = String? Function(T?)?;
typedef SingleFieldOnSave<T> = Future<void> Function(T);
typedef SingleFieldConvertFrom<T> = String Function(T);

class SingleFieldFormState<T> extends Equatable {
  final T value;
  final String? validationError;
  final bool buttonEnabled;
  final bool editMode;
  final T? confirmation;
  final String? confirmationError;

  const SingleFieldFormState({
    required this.value,
    required this.validationError,
    required this.buttonEnabled,
    required this.editMode,
    required this.confirmation,
    required this.confirmationError,
  });

  @override
  List<Object?> get props => [
        value,
        validationError,
        buttonEnabled,
        editMode,
        confirmation,
        confirmationError,
      ];
}

abstract class SingleFieldFormEvent<T> {}

class SingleFieldFormChanged<T> extends SingleFieldFormEvent<T> {
  final T value;

  SingleFieldFormChanged(this.value);
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
  final SingleFieldValidate<T>? validator;
  final String? Function(T?, T?)? confermationValidator;

  late SingleFieldConvertFrom<T> convertFrom;
  late TextEditingController controller;
  late TextEditingController confirmationController;

  SingleFieldFormBloc(
    this.initialValue, {
    SingleFieldConvertFrom<T>? convertFrom,
    this.withEditMode = false,
    this.validator,
    this.confermationValidator,
  }) : super(
          SingleFieldFormState<T>(
            value: initialValue,
            validationError: null,
            buttonEnabled: false,
            editMode: !withEditMode,
            confirmation: null,
            confirmationError: null,
          ),
        ) {
    this.convertFrom = convertFrom ?? (T value) => value.toString();
    controller = TextEditingController(text: this.convertFrom(initialValue));
    confirmationController = TextEditingController(text: '');

    on<SingleFieldFormChanged<T>>(
      (event, Emitter emit) {
        final String? validationError =
            (event.value == initialValue || validator == null)
                ? null
                : validator!(event.value);
        final String? confirmationError =
            confirm(event.value, state.confirmation);
        emit(
          SingleFieldFormState<T>(
            value: event.value,
            validationError: validationError,
            buttonEnabled: validate(
              event.value,
              validationError,
              confirmationError,
            ),
            editMode: state.editMode,
            confirmation: state.confirmation,
            confirmationError: confirmationError,
          ),
        );
      },
    );

    on<SingleFieldFormSave<T>>(
      (event, Emitter emit) async {
        if (state.value != initialValue) {
          try {
            emit(
              SingleFieldFormState<T>(
                value: state.value,
                validationError: state.validationError,
                buttonEnabled: false,
                editMode: state.editMode,
                confirmation: state.confirmation,
                confirmationError: state.confirmationError,
              ),
            );
            await event.onSave(state.value);
          } catch (e, s) {
            debugPrint(
              '\nInvoked event.onSaveError() on SingleFieldFormSave:'
              '\n$e\n$s',
            );
            emit(
              SingleFieldFormState<T>(
                value: state.value,
                validationError: state.validationError,
                buttonEnabled: state.value != initialValue,
                editMode: state.editMode,
                confirmation: state.confirmation,
                confirmationError: state.confirmationError,
              ),
            );
            event.onSaveError();
          }
        }
      },
    );

    on<SingleFieldFormReset<T>>(
      (event, Emitter emit) async {
        final String? confirmationError =
            confirm(initialValue, state.confirmation);
        emit(
          SingleFieldFormState<T>(
            value: initialValue,
            validationError: null,
            buttonEnabled: false,
            editMode: !withEditMode,
            confirmation: state.confirmation,
            confirmationError: confirmationError,
          ),
        );
      },
    );

    on<SingleFieldFormSetEditMode<T>>(
      (event, Emitter emit) {
        emit(
          SingleFieldFormState<T>(
            value: initialValue,
            validationError: null,
            buttonEnabled: false,
            editMode: true,
            confirmation: null,
            confirmationError: null,
          ),
        );
      },
    );

    on<SingleFieldFormConfirmed<T>>(
      (event, Emitter emit) {
        final String? confirmationError =
            confirm(state.value, event.confirmation);
        emit(
          SingleFieldFormState<T>(
            value: state.value,
            validationError: state.validationError,
            buttonEnabled: validate(
              state.value,
              state.validationError,
              confirmationError,
            ),
            editMode: state.editMode,
            confirmation: event.confirmation,
            confirmationError: confirmationError,
          ),
        );
      },
    );

    on<SingleFieldFormConfirmationReset<T>>(
      (event, emit) async {
        final String? confirmationError = confirm(initialValue, null);
        emit(
          SingleFieldFormState<T>(
            value: state.value,
            validationError: state.validationError,
            buttonEnabled: false,
            editMode: state.editMode,
            confirmation: null,
            confirmationError: confirmationError,
          ),
        );
      },
    );
  }

  String? confirm(T? value, T? confirmation) => confermationValidator == null
      ? null
      : confermationValidator!(value, confirmation);

  bool validate(
    T value,
    String? validationError,
    String? confirmationError,
  ) =>
      value != initialValue &&
      validationError == null &&
      confirmationError == null;
}
