import {logger} from "firebase-functions";
import {app, firestore} from "firebase-admin";
import {createHash} from "crypto";
import {AxiosStatic} from "axios";
import {nanoid} from "nanoid";
import {createAuthUser} from "./users";

export const getSys = async (
    firebase: app.App,
): Promise<firestore.DocumentSnapshot | null> => {
  const db = firebase.firestore();
  const sys = await db.collection("service").doc("sys").get();
  return sys.exists ? sys : null;
};

export const updateVersion = async (
    sys: firestore.DocumentSnapshot,
    axios: AxiosStatic,
): Promise<boolean> => {
  const res = await axios.get(
      `${sys.get("url")}version.json?check=${new Date().getTime()}`,
  );
  const {version} = res.data;

  if (version !== sys.get("version")) {
    logger.info(version);

    await sys.ref.update({
      version,
      updatedAt: new Date(),
    });

    return true;
  }

  return false;
};

export const updateData = async (
    firebase: app.App,
    sys: firestore.DocumentSnapshot,
): Promise<void> => {
  const db = firebase.firestore();
  const dataVersion = sys.get("dataVersion") || 0;

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
    await sys.ref.update({
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
  await serviceRef.doc("sys").set({
    version: "1.0.0",
    url,
    createdAt: ts,
    updatedAt: ts,
  });

  await serviceRef.doc("inv").set({
    seed,
    expiration: 3 * 24 * 3600 * 1000,
    createdAt: ts,
    updatedAt: ts,
  });

  await serviceRef.doc("copyright").set({
    text: `Copyright &copy; 2021 Michinobu Maeda.

    The source code for this app is distributed under the MIT license.

    <https://github.com/MichinobuMaeda/amberpencil>
`,
    createdAt: ts,
    updatedAt: ts,
  });

  await serviceRef.doc("policy").set({
    text: `### Heading 3

    The quick brown fox jumps over the lazy dog.
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

  return serviceRef.doc("sys").get();
};
