String? requiredValidator(String? value) =>
    (value != null && value.isNotEmpty) ? null : '必ず入力してください。';

String? emailValidator(String? value) => RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value ?? '')
        ? null
        : '正しい書式のメールアドレスを入力してください。';

String? passwordValidator(String? value) => (value == null || value.length < 8)
    ? '8文字以上としてください。'
    : (((RegExp(r"[A-Z]").hasMatch(value) ? 1 : 0) +
                (RegExp(r"[a-z]").hasMatch(value) ? 1 : 0) +
                (RegExp(r"[0-9]").hasMatch(value) ? 1 : 0) +
                (RegExp(r"[^A-Za-z0-9]").hasMatch(value) ? 1 : 0)) <
            3)
        ? '3種類以上の文字（大文字・小文字・数字・記号）を使ってください。'
        : null;

String? confermValidator(String? value, String? confirmation) =>
    value == confirmation ? null : '確認の入力内容が一致しません。';
