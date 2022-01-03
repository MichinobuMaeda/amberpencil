import 'package:amberpencil/config/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as markdown;
import '../models/app_state_provider.dart';
import '../screens/scroll_screen.dart';

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppStateProvider appState =
        Provider.of<AppStateProvider>(context, listen: false);

    return ScrollScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    showAboutDialog(
                      context: context,
                      applicationIcon: const Image(
                        image: AssetImage('assets/images/logo.png'),
                        width: 48,
                        height: 48,
                      ),
                      applicationName: appState.appInfo.name,
                      applicationVersion: appState.appInfo.version,
                      applicationLegalese: appState.appInfo.copyright,
                    );
                  },
                  icon: const Icon(Icons.copyright),
                  label: const Text('著作権'),
                ),
              ),
            ],
          ),
          Flex(
            direction: Axis.vertical,
            children: const [
              Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'プライバシー・ポリシー',
                  style: TextStyle(fontSize: fontSizeH2),
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          ),
          Flex(
            direction: Axis.vertical,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Html(
                  data: markdown.markdownToHtml(
                    '''### Heading Level 3

The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.

- Item 1
- Item 2
- Item 3
    1. Item 3-1
    2. Item 3-2
    3. Item 3-3

### Heading Level 3

The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.

- Item 1
- Item 2
- Item 3
    1. Item 3-1
    2. Item 3-2
    3. Item 3-3

### Heading Level 3

The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.

- Item 1
- Item 2
- Item 3
    1. Item 3-1
    2. Item 3-2
    3. Item 3-3
''',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
