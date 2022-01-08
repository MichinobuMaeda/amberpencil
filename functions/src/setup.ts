import {logger, config} from "firebase-functions";
import {app, firestore} from "firebase-admin";
import {createHash} from "crypto";
import {nanoid} from "nanoid";
import {createAuthUser} from "./users";

export const getConf = async (
    firebase: app.App,
): Promise<firestore.DocumentSnapshot | null> => {
  const db = firebase.firestore();
  const conf = await db.collection("service").doc("conf").get();
  return conf.exists ? conf : null;
};

export const updateVersion = async (
    conf: firestore.DocumentSnapshot,
    functionsConfig: config.Config,
): Promise<boolean> => {
  const version = functionsConfig.initial.version;

  if (version !== conf.get("version")) {
    logger.info(version);

    await conf.ref.update({
      version,
      updatedAt: new Date(),
    });

    return true;
  }

  return false;
};

export const updateData = async (
    firebase: app.App,
    conf: firestore.DocumentSnapshot,
): Promise<void> => {
  const db = firebase.firestore();
  const dataVersion = conf.get("dataVersion") || 0;

  if (dataVersion < 1) {
    const accounts = await db.collection("accounts").get();
    await Promise.all(accounts.docs.map(async (
        doc: firestore.DocumentSnapshot,
    ) => {
      doc.ref.update({
        themeMode: doc.get("themeMode") || 0,
        updatedAt: new Date(),
      });
    }));
    await conf.ref.update({
      dataVersion: 1,
      updatedAt: new Date(),
    });
  }


  // for data version 1
  // for data version 2
  //  ... ...
  // for data version n
};

export const install = async (
    firebase: app.App,
    email: string,
    password: string,
    url: string,
): Promise<firestore.DocumentSnapshot> => {
  const db = firebase.firestore();
  const name = "Primary user";
  const ts = new Date();

  const hash = createHash("sha256");
  hash.update(nanoid());
  hash.update(new Date().toISOString());
  hash.update(name);
  hash.update(email);
  hash.update(password);
  hash.update(url);
  const seed = hash.digest("hex");

  const serviceRef = db.collection("service");
  await serviceRef.doc("conf").set({
    version: "1.0.0+1",
    url,
    seed,
    invitationExpirationTime: 3 * 24 * 3600 * 1000,
    policy: `## Privacy policy

### Heading 3

The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.
The quick brown fox jumps over the lazy dog.

1. Item 1
2. Item 2
3. Item 3
    * Item 3-1
    * Item 3-2
    * Item 3-3

\`\`\`
$ echo Code Block
\`\`\`

<https://flutter.dev/>

[Flutter](https://flutter.dev/)
`,
    createdAt: ts,
    updatedAt: ts,
  });

  const testers = "testers";
  const uid = await createAuthUser(
      firebase,
      {
        name,
        admin: true,
        tester: true,
        group: testers,
        email,
        password,
      },
  );

  await db.collection("groups").doc(testers).set({
    name: "テスト",
    desc: "テスト用のグループ",
    accounts: [uid],
    createdAt: ts,
    updatedAt: ts,
    deletedAt: null,
  });

  return serviceRef.doc("conf").get();
};
