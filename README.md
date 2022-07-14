# amberpencil

## Prerequisites

- git
- fvm
- nvm

```
$ nvm install v16.14.2
$ fvm install 3.0.4
```

## Getting Started

```
$ git clone git@github.com:MichinobuMaeda/amberpencil.git
$ cd amberpencil
$ nvm use
$ npm --prefix functions install
$ npm install
$ fvm flutter pub get
$ npm test
$ npm start
```

## Crete this project

https://console.firebase.google.com/project/amberpencil-test/overview

- Project settings
    - Project name: amberpencil
    - Environment type: Unspecified
    - Public-facing name: amberpencil-test
    - Support email: my email address
    - Web apps
        - App nickname: Amber pencil test
- Usage and billing
    - Details & settings
        - Firebase billing plan: Blaze
- Authentication
    - Sign-in method
        - Sign-in providers
            - Email/Password: Enable
                - Email link (passwordless sign-in): Enable
    - Templates
        - Template language: Japanese

```
$ fvm global 3.0.4
$ fvm flutter create amberpencil --template=app --platforms=web
$ cd amberpencil
$ fvm use 3.0.4
$ fvm flutter --version
Flutter 3.0.4 ...

$ echo 16 > .nvmrc
$ nvm use
$ node --version
v16.14.2

$ npx --version
8.13.2

$ npm init
$ npm install firebase-tools
$ npx firebase --version
11.2.2

$ npx firebase login
$ npx firebase init

? Which Firebase features do you want to set up for this directory? Press Space to select features, then Enter to confirm your choices.
 Firestore: Configure security rules and indexes files for Firestore,
 Functions: Configure a Cloud Functions directory and its files,
 Hosting: Configure files for Firebase Hosting and (optionally) set up GitHub Action deploys, Hosting: Set up GitHub Action deploys,
 Storage: Configure a security rules file for Cloud Storage,
 Emulators: Set up local emulators for Firebase products

=== Project Setup

? Please select an option: Use an existing project
? Select a default Firebase project for this directory: amberpencil-test (amberpencil-test)

=== Firestore Setup

? What file should be used for Firestore Rules? firestore.rules
? What file should be used for Firestore indexes? firestore.indexes.json

=== Functions Setup

? What language would you like to use to write Cloud Functions? JavaScript
? Do you want to use ESLint to catch probable bugs and enforce style? Yes
? Do you want to install dependencies with npm now? Yes

=== Hosting Setup

? What do you want to use as your public directory? build/web
? Configure as a single-page app (rewrite all urls to /index.html)? No
? Set up automatic builds and deploys with GitHub? Yes
? For which GitHub repository would you like to set up a GitHub workflow? (format: userrepository) MichinobuMaeda/amberpencil
? Set up the workflow to run a build script before every deploy? No
? Set up automatic deployment to your site's live channel when a PR is merged? Yes
? What is the name of the GitHub branch associated with your site's live channel? main
i  Action required: Visit this URL to revoke authorization for the Firebase CLI GitHub OAuth App:
https://github.com/settings/connections/applications/89cf50f02ac6aaed3484

=== Storage Setup

? What file should be used for Storage Rules? storage.rules

=== Emulators Setup

? Which Firebase emulators do you want to set up? Press Space to select emulators, then Enter to confirm your choices. Au
thentication Emulator, Functions Emulator, Firestore Emulator, Storage Emulator
? Which port do you want to use for the auth emulator? 9099
? Which port do you want to use for the functions emulator? 5001
? Which port do you want to use for the firestore emulator? 8080
? Which port do you want to use for the storage emulator? 9199
? Would you like to enable the Emulator UI? Yes
? Which port do you want to use for the Emulator UI (leave empty to use any available port)? 4040
? Would you like to download the emulators now? No

$ npx firebase login:ci
```

https://github.com/MichinobuMaeda/amberpencil

- Settings
    - Secrets
        - Acrions
            - `FIREBASE_TOKEN_AMBERPENCIL_TEST`: firebase token
            - `FIREBASE_API_KEY_AMBERPENCIL_TEST`: firebase Web API Key
