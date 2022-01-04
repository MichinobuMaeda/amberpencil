import "package:universal_html/html.dart" as html;

void reloadWebAapp() {
  html.window.location.reload();
}

String getCurrentUrl() => html.window.location.href;

const String emailKey = 'amberpencil_email';

void saveSignInEmail(String email) {
  html.window.localStorage[emailKey] = email;
}

String? loadSignInEmail() {
  final String? email = html.window.localStorage[emailKey];
  html.window.localStorage.remove(emailKey);
  return email;
}
