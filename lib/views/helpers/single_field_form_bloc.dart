import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

typedef SingleFieldValidate<T> = String? Function(T?)?;
typedef SingleFieldOnSave<T> = Future<void> Function(T, VoidCallback);
typedef SingleFieldConvertFrom<T> = String Function(T);

class SingleFieldFormState<T> extends Equatable {
  final T initialValue;
  final bool withEditMode;
  final SingleFieldValidate<T>? validator;
  final String? Function(T?, T?)? confermationValidator;
  final T value;
  final T confirmation;
  final bool editMode;
  final bool waitProcess;

  const SingleFieldFormState({
    required this.initialValue,
    required this.withEditMode,
    required this.validator,
    required this.confermationValidator,
  })  : value = initialValue,
        confirmation = initialValue,
        editMode = !withEditMode,
        waitProcess = false;

  SingleFieldFormState.copyWith(
    SingleFieldFormState<T> current, {
    T? value,
    T? confirmation,
    bool? editMode,
    bool? waitProcess,
  })  : initialValue = current.initialValue,
        value = value ?? current.value,
        withEditMode = current.withEditMode,
        editMode = editMode ?? current.editMode,
        confirmation = confirmation ?? current.confirmation,
        validator = current.validator,
        confermationValidator = current.confermationValidator,
        waitProcess = waitProcess ?? current.waitProcess;

  String? get validationError =>
      (value == initialValue || validator == null) ? null : validator!(value);

  String? get confirmationError => confermationValidator == null
      ? null
      : confermationValidator!(value, confirmation);

  bool get buttonEnabled =>
      !waitProcess &&
      value != initialValue &&
      validationError == null &&
      confirmationError == null;

  @override
  List<Object?> get props => [
        initialValue,
        withEditMode,
        validator,
        confermationValidator,
        value,
        confirmation,
        editMode,
        waitProcess,
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
  late SingleFieldConvertFrom<T> convertFrom;
  late TextEditingController controller;
  late TextEditingController confirmationController;

  SingleFieldFormBloc(
    T initialValue, {
    SingleFieldConvertFrom<T>? convertFrom,
    bool withEditMode = false,
    SingleFieldValidate<T>? validator,
    String? Function(T?, T?)? confermationValidator,
  }) : super(
          SingleFieldFormState<T>(
            initialValue: initialValue,
            withEditMode: withEditMode,
            validator: validator,
            confermationValidator: confermationValidator,
          ),
        ) {
    this.convertFrom = convertFrom ?? (T value) => value.toString();
    controller = TextEditingController(text: this.convertFrom(initialValue));
    confirmationController = TextEditingController(text: '');

    on<SingleFieldFormChanged<T>>(
      (event, Emitter emit) {
        emit(SingleFieldFormState.copyWith(state, value: event.value));
      },
    );

    on<SingleFieldFormSave<T>>(
      (event, Emitter emit) async {
        if (state.value != initialValue) {
          emit(SingleFieldFormState.copyWith(state, waitProcess: true));
          await event.onSave(state.value, () {
            emit(SingleFieldFormState.copyWith(state, waitProcess: false));
            event.onSaveError();
          });
        }
      },
    );

    on<SingleFieldFormReset<T>>(
      (event, Emitter emit) async {
        emit(SingleFieldFormState.copyWith(state, value: state.initialValue));
      },
    );

    on<SingleFieldFormSetEditMode<T>>(
      (event, Emitter emit) {
        emit(SingleFieldFormState.copyWith(state, editMode: true));
      },
    );

    on<SingleFieldFormConfirmed<T>>(
      (event, Emitter emit) {
        emit(SingleFieldFormState.copyWith(
          state,
          confirmation: event.confirmation,
        ));
      },
    );

    on<SingleFieldFormConfirmationReset<T>>(
      (event, emit) {
        emit(SingleFieldFormState.copyWith(
          state,
          confirmation: state.initialValue,
        ));
      },
    );
  }
}
