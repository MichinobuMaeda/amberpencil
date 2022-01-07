# Create this project

[README](../README.md)

Prerequisites: [Development](./dev.md)

## Flutter project

```
$ flutter create --platforms web amberpencil
$ cd amberpencil
$ git init
$ git add .
$ git commit -m "first commit"
$ git branch -M main
$ git remote add origin git@github.com:MichinobuMaeda/amberpencil.git
$ git push -u origin main
```

## Firebase project

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


<https://console.firebase.google.com/>
- Add project
    - Project name: amberpencil-test
    - ... ...

```
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

## Firebase secrets

```
$ firebase init hosting
? What do you want to use as your public directory? build/web
? Configure as a single-page app (rewrite all urls to /index.html)? No
? Set up automatic builds and deploys with GitHub? No
? File build/web/index.html already exists. Overwrite? No

$ firebase use amberpencil-test
$ firebase init hosting:github
? For which GitHub repository would you like to set up a GitHub workflow? (format: user/repository) MichinobuMaeda/amberpencil
? Set up the workflow to run a build script before every deploy? No
? Set up automatic deployment to your site's live channel when a PR is merged? No
i  Action required: Visit this URL to revoke authorization for the Firebase CLI GitHub OAuth App:
https://github.com/settings/connections/applications/89cf50f02ac6aaed3484

$ firebase login:ci

1// ... ... ...

$ gh secret set FIREBASE_TOKEN_AMBERPENCIL_TEST
? Paste your secret *******

$ firebase functions:config:set \
    initial.email="michinobumaeda@gmail.com"  \
    initial.password="8442rUnt" \
    initial.url="https://amberpencil-test.web.app/"
$ firebase deploy --only functions

$ firebase use amberpencil
$ firebase init hosting:github
? For which GitHub repository would you like to set up a GitHub workflow? (format: user/repository) MichinobuMaeda/amberpencil
? Set up the workflow to run a build script before every deploy? Yes
? What script should be run before every deploy?
? Set up automatic deployment to your site's live channel when a PR is merged? Yes
? What is the name of the GitHub branch associated with your site's live channel? main

$ firebase functions:config:set \
    initial.email="michinobumaeda@gmail.com"  \
    initial.password="8442rUnt" \
    initial.url="https://amberpencil-test.web.app/"
$ firebase deploy --only functions
```

Install [Github CLI](https://cli.github.com/), or set secrets on web.


```
$ gh secret list
FIREBASE_SERVICE_ACCOUNT_AMBERPENCIL       Updated 2022-01-07
FIREBASE_SERVICE_ACCOUNT_AMBERPENCIL_TEST  Updated 2022-01-07

$ firebase login:ci

1// ... ... ...

$ gh secret set FIREBASE_TOKEN_AMBERPENCIL
? Paste your secret *******

$ gh secret set FIREBASE_API_KEY_AMBERPENCIL_TEST
? Paste your secret *******

$ gh secret set FIREBASE_API_KEY_AMBERPENCIL
? Paste your secret *******

$ gh secret list
FIREBASE_API_KEY_AMBERPENCIL               Updated 2022-01-07
FIREBASE_API_KEY_AMBERPENCIL_TEST          Updated 2022-01-07
FIREBASE_SERVICE_ACCOUNT_AMBERPENCIL       Updated 2022-01-07
FIREBASE_SERVICE_ACCOUNT_AMBERPENCIL_TEST  Updated 2022-01-07
FIREBASE_TOKEN_AMBERPENCIL                 Updated 2022-01-07
FIREBASE_TOKEN_AMBERPENCIL_TEST            Updated 2022-01-07
```
