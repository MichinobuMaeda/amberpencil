import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:equatable/equatable.dart';

class SingleFieldFormState<T> extends Equatable {
  final T initialValue;
  final bool withEditMode;
  final String? Function(T?)? validator;
  final String? Function(T?, T?)? confermationValidator;
  final T value;
  final T confirmation;
  final bool editMode;

  const SingleFieldFormState({
    required this.initialValue,
    required this.withEditMode,
    required this.validator,
    required this.confermationValidator,
  })  : value = initialValue,
        confirmation = initialValue,
        editMode = !withEditMode;

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
        confermationValidator = current.confermationValidator;

  String? get validationError =>
      (value == initialValue || validator == null) ? null : validator!(value);

  String? get confirmationError => confermationValidator == null
      ? null
      : confermationValidator!(value, confirmation);

  bool get ready =>
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

class SingleFieldFormReset<T> extends SingleFieldFormEvent<T> {}

class SingleFieldFormConfirmationReset<T> extends SingleFieldFormEvent<T> {}

class SingleFieldFormSetEditMode<T> extends SingleFieldFormEvent<T> {
  SingleFieldFormSetEditMode();
}

String defaultConvertFrom<T>(T value) => value.toString();

class SingleFieldFormBloc<T>
    extends Bloc<SingleFieldFormEvent<T>, SingleFieldFormState<T>> {
  final String Function(T) convertFrom;
  late TextEditingController controller;
  late TextEditingController confirmationController;

  SingleFieldFormBloc(
    T initialValue, {
    String Function(T)? convertFrom,
    bool withEditMode = false,
    String? Function(T?)? validator,
    String? Function(T?, T?)? confermationValidator,
  })  : convertFrom = convertFrom ?? defaultConvertFrom,
        super(
          SingleFieldFormState<T>(
            initialValue: initialValue,
            withEditMode: withEditMode,
            validator: validator,
            confermationValidator: confermationValidator,
          ),
        ) {
    controller = TextEditingController(text: this.convertFrom(initialValue));
    confirmationController = TextEditingController(text: '');

    on<SingleFieldFormChanged<T>>(
      (event, Emitter emit) {
        emit(SingleFieldFormState.copyWith(state, value: event.value));
      },
    );

    on<SingleFieldFormReset<T>>(
      (event, Emitter emit) {
        emit(SingleFieldFormState.copyWith(
          state,
          value: state.initialValue,
          confirmation: state.initialValue,
          editMode: false,
        ));
        controller.text = this.convertFrom(state.initialValue);
        controller.selection = TextSelection(
          baseOffset: controller.text.length,
          extentOffset: controller.text.length,
        );
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
        confirmationController.text = this.convertFrom(state.initialValue);
      },
    );
  }
}
