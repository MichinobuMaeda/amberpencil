const test = require("firebase-functions-test");

const {EMPTY_EMAIL} = require("./utils");
const firebase = require("./firebase");
const {clearAll} = require("./testutils");
const {
  onCreateAccount,
  onUpdateAccount,
  invite,
  getToken,
} = require("./accounts");

afterEach(async function() {
  jest.clearAllMocks();
  await clearAll();
});

describe("onCreateAccount", () => {
  it("connects auth user" +
    "with same email and set display name.", async function() {
    const auth = firebase.auth();
    const db = firebase.firestore();
    const name = "User 02";
    const email = "user02@example.com";
    const {uid} = await auth.createUser({email});
    const doc = await db.collection("accounts").add({name, email});

    await onCreateAccount(firebase, await doc.get());

    const user = await auth.getUser(uid);
    expect(user.displayName).toEqual(name);

    const account = await doc.get();
    expect(account.get("uid")).toEqual(uid);
  });

  it("creates auth user with email.", async function() {
    const auth = firebase.auth();
    const db = firebase.firestore();
    const name = "User 02";
    const email = "user02@example.com";
    const doc = await db.collection("accounts").add({name, email});

    await onCreateAccount(firebase, await doc.get());

    const account = await doc.get();
    expect(account.get("uid")).toBeDefined();

    const user = await auth.getUser(account.get("uid"));
    expect(user.displayName).toEqual(name);
    expect(user.email).toEqual(email);
  });

  it("creates auth user without email.", async function() {
    const auth = firebase.auth();
    const db = firebase.firestore();
    const name = "";
    const doc = await db.collection("accounts").add({name});

    await onCreateAccount(firebase, await doc.get());

    const account = await doc.get();
    expect(account.get("uid")).toBeDefined();

    const user = await auth.getUser(account.get("uid"));
    expect(user.displayName).toEqual(name);
    expect(user.email).not.toBeDefined();
  });
});

describe("onUpdateAccount", () => {
  it("creates auth user for empty uid.", async function() {
    const auth = firebase.auth();
    const db = firebase.firestore();
    const name = "User 02";
    const email = "user02@example.com";
    const doc = await db.collection("accounts").add({name, email});

    await onUpdateAccount(firebase, {
      before: test().firestore.makeDocumentSnapshot({name}, doc.path),
      after: await doc.get(),
    });

    const account = await doc.get();
    expect(account.get("uid")).toBeDefined();

    const user = await auth.getUser(account.get("uid"));
    expect(user.displayName).toEqual(name);
    expect(user.email).toEqual(email);
  });

  it("sets name of auth user.", async function() {
    const auth = firebase.auth();
    const db = firebase.firestore();
    const name = "";
    const email = "user02@example.com";
    const {uid} = await auth.createUser({displayName: "Test"});
    const doc = await db.collection("accounts").add({uid, name, email});

    await onUpdateAccount(firebase, {
      before: test().firestore.makeDocumentSnapshot({uid, name}, doc.path),
      after: await doc.get(),
    });

    const user = await auth.getUser(uid);
    expect(user.displayName).toEqual(name);
    expect(user.email).toEqual(email);
  });

  it("resets name of auth user for empty name.", async function() {
    const auth = firebase.auth();
    const db = firebase.firestore();
    const name = "User 02";
    const email = "user02@example.com";
    const {uid} = await auth.createUser({displayName: "Test", email});
    const doc = await db.collection("accounts").add({uid, name: "", email});

    await onUpdateAccount(firebase, {
      before: test().firestore
          .makeDocumentSnapshot({uid, name, email}, doc.path),
      after: await doc.get(),
    });

    const user = await auth.getUser(uid);
    expect(user.displayName).toEqual("");
    expect(user.email).toEqual(email);
  });

  it("sets email of auth user.", async function() {
    const auth = firebase.auth();
    const db = firebase.firestore();
    const name = "User 02";
    const email = "user02@example.com";
    const {uid} = await auth.createUser({displayName: name});
    const doc = await db.collection("accounts").add({uid, name, email});

    await onUpdateAccount(firebase, {
      before: test().firestore.makeDocumentSnapshot({uid, name}, doc.path),
      after: await doc.get(),
    });

    const user = await auth.getUser(uid);
    expect(user.displayName).toEqual(name);
    expect(user.email).toEqual(email);
  });

  it("resets email of auth user for empty email.", async function() {
    const auth = firebase.auth();
    const db = firebase.firestore();
    const name = "User 02";
    const email = "user02@example.com";
    const {uid} = await auth.createUser({displayName: "", email});
    const doc = await db.collection("accounts").add({uid, name, email: ""});

    await onUpdateAccount(firebase, {
      before: test().firestore
          .makeDocumentSnapshot({uid, name, email}, doc.path),
      after: await doc.get(),
    });

    const user = await auth.getUser(uid);
    expect(user.displayName).toEqual(name);
    expect(user.email).toEqual(EMPTY_EMAIL);
  });
});

describe("invite", () => {
  it("sets invitation.", async function() {
    const db = firebase.firestore();
    const name = "User 02";
    const invitedBy = "user01";
    const doc = await db.collection("accounts").add({name});

    await invite({invitee: doc.id})(firebase, invitedBy);

    const account = await doc.get();
    expect(account.get("invitation")).toBeDefined();
    expect(account.get("invitedBy")).toEqual(invitedBy);
    expect(account.get("invitedAt")).toBeDefined();
  });
});

describe("getToken", () => {
  it("rejects account without invitation.", async function() {
    const db = firebase.firestore();
    const seed = "test";
    const invExp = 1000000;
    await db.collection("service").doc("conf").set({seed, invExp});
    const name = "User 02";
    const doc = await db.collection("accounts").add({name});
    const code = "dummy";

    await expect(
        function() {
          return getToken(firebase, {code});
        },
    ).rejects.toThrow("No record");

    const account = await doc.get();
    expect(account.get("invitation")).toBeFalsy();
    expect(account.get("invitedBy")).toBeFalsy();
    expect(account.get("invitedAt")).toBeFalsy();
  });

  it("rejects account without uid.", async function() {
    const db = firebase.firestore();
    const seed = "test";
    const invExp = 1000000;
    await db.collection("service").doc("conf").set({seed, invExp});
    const name = "User 02";
    const invitedBy = "user01";
    const doc = await db.collection("accounts").add({name});
    const code = await invite({invitee: doc.id})(firebase, invitedBy);

    await expect(
        () => getToken(firebase, {code}),
    ).rejects.toThrow(`Invalid status: ${doc.id} uid`);

    const account = await doc.get();
    expect(account.get("invitation")).toBeFalsy();
    expect(account.get("invitedBy")).toBeFalsy();
    expect(account.get("invitedAt")).toBeFalsy();
  });

  it("rejects account without invitation records.", async function() {
    const db = firebase.firestore();
    const seed = "test";
    const invExp = 1000000;
    await db.collection("service").doc("conf").set({seed, invExp});
    const uid = "user02";
    const name = "User 02";
    const invitedBy = "user01";
    const doc = await db.collection("accounts").add({uid, name});
    const code = await invite({invitee: doc.id})(firebase, invitedBy);
    await doc.update({
      invitedAt: null,
      invitedBy: null,
    });

    await expect(
        function() {
          return getToken(firebase, {code});
        },
    ).rejects.toThrow(`Invalid status: ${doc.id} invitedAt, invitedBy`);

    const account = await doc.get();
    expect(account.get("invitation")).toBeFalsy();
    expect(account.get("invitedBy")).toBeFalsy();
    expect(account.get("invitedAt")).toBeFalsy();
  });

  it("rejects expired invitation.", async function() {
    const db = firebase.firestore();
    const seed = "test";
    const invExp = 1000000;
    await db.collection("service").doc("conf").set({seed, invExp});
    const uid = "user02";
    const name = "User 02";
    const invitedBy = "user01";
    const doc = await db.collection("accounts").add({uid, name});
    const code = await invite({invitee: doc.id})(firebase, invitedBy);
    await doc.update({
      invitedAt: new Date(new Date().getTime() - invExp - 1),
    });

    await expect(
        function() {
          return getToken(firebase, {code});
        },
    ).rejects.toThrow(`Expired: ${doc.id}`);

    const account = await doc.get();
    expect(account.get("invitation")).toBeFalsy();
    expect(account.get("invitedBy")).toBeFalsy();
    expect(account.get("invitedAt")).toBeFalsy();
  });

  it("gets invitation token.", async function() {
    const db = firebase.firestore();
    const seed = "test";
    const invExp = 1000000;
    await db.collection("service").doc("conf").set({seed, invExp});
    const uid = "user02";
    const name = "User 02";
    const invitedBy = "user01";
    const doc = await db.collection("accounts").add({uid, name});
    const code = await invite({invitee: doc.id})(firebase, invitedBy);

    const token = await getToken(firebase, {code});

    expect(token).toBeDefined();

    const account = await doc.get();
    expect(account.get("invitation")).toBeDefined();
    expect(account.get("invitedBy")).toBeDefined();
    expect(account.get("invitedAt")).toBeDefined();
  });
});
