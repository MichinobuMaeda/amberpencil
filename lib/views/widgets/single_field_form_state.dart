import 'package:flutter/material.dart';

typedef OnFormSaveCallBack<T> = Future<void> Function(T value);

class SingleFieldFormState<T> extends ChangeNotifier {
  final T initialValue;
  final VoidCallback? _onChange;
  final bool withEditMode;
  final GlobalKey<FormState> formKey;
  T _value;
  bool _waiting = false;
  bool _edit;

  SingleFieldFormState({
    required this.formKey,
    required this.initialValue,
    VoidCallback? onChange,
    this.withEditMode = false,
  })  : _value = initialValue,
        _onChange = onChange,
        _edit = !withEditMode;

  T get value => _value;

  void setValue(T val) {
    if (_value != val) {
      _value = val;
      _waiting = false;
      if (_onChange != null) _onChange!();
      notifyListeners();
    }
  }

  bool get edit => _edit;
  void enableEdit() => _setEdit(true);
  void disableEdit() => _setEdit(false);

  void _setEdit(bool val) {
    assert(withEditMode, 'The property withEditMode is false.');
    if (_edit != val) {
      _edit = val;
      _value = initialValue;
      notifyListeners();
    }
  }

  Future<void> Function()? save({
    required OnFormSaveCallBack<T> onSave,
    VoidCallback? onError,
  }) =>
      (_waiting ||
              _value == initialValue ||
              formKey.currentState?.validate() == false)
          ? null
          : () async {
              _waiting = true;
              try {
                await onSave(_value);
              } catch (e, s) {
                debugPrint('$e\n$s');
                _waiting = false;
                if (onError != null) onError();
                notifyListeners();
              }
            };

  void reset() {
    _value = initialValue;
    _waiting = false;
    formKey.currentState?.reset();
    notifyListeners();
  }
}
