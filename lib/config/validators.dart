import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

String? Function(String?) requiredValidator(
  BuildContext context,
) =>
    (
      String? value,
    ) =>
        (value != null && value.isNotEmpty)
            ? null
            : AppLocalizations.of(context)!.errorRequired;

String? Function(String?) emailValidator(
  BuildContext context,
) =>
    (
      String? value,
    ) =>
        RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
        ).hasMatch(value ?? '')
            ? null
            : AppLocalizations.of(context)!.errorEmailFormat;

String? Function(String?) passwordValidator(
  BuildContext context,
) =>
    (
      String? value,
    ) =>
        (value == null || value.length < 8)
            ? AppLocalizations.of(context)!.errorPasswordLength
            : (((RegExp(r"[A-Z]").hasMatch(value) ? 1 : 0) +
                        (RegExp(r"[a-z]").hasMatch(value) ? 1 : 0) +
                        (RegExp(r"[0-9]").hasMatch(value) ? 1 : 0) +
                        (RegExp(r"[^A-Za-z0-9]").hasMatch(value) ? 1 : 0)) <
                    3)
                ? AppLocalizations.of(context)!.errorPasswordChars
                : null;

String? Function(String?, String?) confermationValidator(
  BuildContext context,
) =>
    (
      String? value,
      String? confirmation,
    ) =>
        (value ?? '') == (confirmation ?? '')
            ? null
            : AppLocalizations.of(context)!.errorConfirmation;
