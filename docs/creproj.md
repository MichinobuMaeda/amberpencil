# Create this project

[README](../README.md)

Prerequisites: [Development](./dev.md)

<https://console.firebase.google.com/>
- Add project
    - Project name: amberpencil
    - Enable Google Analytics for thid project
        - Choose or create a Google Analytics account: amberpencil
        - Analytics location: Japan
- Project settings
    - Your project
        - Default GCP resource location: asia-northeast1 ( Tokyo )
        - Support email: my address
    - Select a platform to get started: </> ( Web )
        - App nickname: Amber pencil
    - Usage and billing
        - Details & settings
            - Modify plan: Blaze
- Firestore
    - Create database: Start in production mode

<https://github.com/MichinobuMaeda/>
- Repositories
    - New
        - Repository name: amberpencil
        - Public

```
$ flutter create --platforms web amberpencil
$ cd amberpencil
$ git init
$ git add .
$ git commit -m "first commit"
$ git branch -M main
$ git remote add origin git@github.com:MichinobuMaeda/amberpencil.git
$ git push -u origin main
$ npm -g install firebase-tools
$ firebase login
$ firebase init functions
=== Project Setup
? Please select an option: Use an existing project
? Select a default Firebase project for this directory: amberpencil (amberpencil)
=== Functions Setup
? What language would you like to use to write Cloud Functions? TypeScript
? Do you want to use ESLint to catch probable bugs and enforce style? Yes
? Do you want to install dependencies with npm now? No

$ cd functions
$ yarn install
$ cd ..
$ npm init
package name: (amberpencil)
version: (1.0.0)
description:
entry point: (index.js)
test command:
git repository: (https://github.com/MichinobuMaeda/amberpencil.git)
keywords:
author: Michinobu Maeda
license: (ISC) BSD-3-Clause

$ yarn -D add firebase-tools
$ npx firebase --version
10.0.1

$ firebase login
$ firebase init
=== Project Setup
? Please select an option: Use an existing project
? Select a default Firebase project for this directory: amberpencile (amberpencil)
=== Functions Setup
? What language would you like to use to write Cloud Functions? TypeScript
? Do you want to use ESLint to catch probable bugs and enforce style? Yes
? Do you want to install dependencies with npm now? No
=== Emulators Setup
? Which Firebase emulators do you want to set up? Press Space to select emulators, then Enter to confirm your choices. Authentica
tion Emulator, Functions Emulator, Firestore Emulator, Storage Emulator
? Which port do you want to use for the auth emulator? 9099
? Which port do you want to use for the functions emulator? 5001
? Which port do you want to use for the firestore emulator? 8080
? Which port do you want to use for the storage emulator? 9199
? Would you like to enable the Emulator UI? Yes
? Which port do you want to use for the Emulator UI (leave empty to use any available port)? 4040
? Would you like to download the emulators now? No

$ yarn --cwd functions install

$ git add .
$ git commit -m "init firebase"
$ git push
```

<https://firebase.flutter.dev/docs/overview>

```
$ flutter pub add firebase_core
$ dart pub global activate flutterfire_cli
$ flutterfire configure
```
