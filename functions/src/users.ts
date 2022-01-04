import {logger, Change} from "firebase-functions";
import {app, auth, firestore} from "firebase-admin";
import {createHash} from "crypto";
import {nanoid} from "nanoid";

export interface UserData {
  name: string,
  admin?: boolean,
  tester?: boolean,
  group?: string,
  email?: string,
  password?: string,
}

export interface UserProfile {
  uid: string,
  displayName: string,
  email: string,
  password: string,
}

export const createAuthUser = async (
    firebase: app.App,
    {
      name, admin, tester, group, email, password,
    }: UserData,
): Promise<string> => {
  logger.info({
    name, admin, tester, group, email, password: !!password,
  });

  if (name.trim().length === 0) {
    throw new Error("Param name is missing.");
  }

  if (email?.trim().length === 0) {
    throw new Error("Param email is empty.");
  }

  if (password?.length === 0) {
    throw new Error("Param password is empty.");
  }

  const db = firebase.firestore();
  const ts = new Date;

  const account = await db.collection("accounts").add({
    name,
    email: email || null,
    valid: true,
    admin,
    tester,
    group: group || null,
    themeMode: null, // added: dataVersion: 1
    invitation: null,
    invitedBy: null,
    invitedAt: null,
    createdAt: ts,
    updatedAt: ts,
    deletedAt: null,
  });

  const uid = account.id;
  const displayName = name;

  const profile = {uid, displayName} as UserProfile;
  if (email) {
    profile.email = email;
    if (password) {
      profile.password = password;
    }
  }
  await firebase.auth().createUser(profile);

  await db.collection("people").doc(uid).set({
    groups: group ? [group] : [],
    createdAt: ts,
    updatedAt: ts,
    deletedAt: null,
  });

  return uid;
};

export const setUserPassword = async (
    firebase: app.App,
    {uid, password}: {uid: string, password: string},
): Promise<void> => {
  if (password.length === 0) {
    throw new Error("Param password is empty.");
  }

  logger.info(`setUserPassword: ${uid}`);
  await firebase.auth().updateUser(uid, {password});
};

export const calcInvitation = (
    code: string,
    seed: string,
): string => {
  const hash = createHash("sha256");
  hash.update(code);
  hash.update(seed);
  return hash.digest("hex");
};

export const invite = async (
    firebase: app.App,
    uid: string,
    invitee: string,
): Promise<string> => {
  const db = firebase.firestore();
  const invitedBy = uid;

  logger.info(`setUserEmail ${JSON.stringify({invitedBy, invitee})}`);
  const inv = await db.collection("service").doc("conf").get();
  const code = nanoid();
  const ts = new Date();
  const invitation = calcInvitation(code, inv.get("seed"));
  await db.collection("accounts").doc(invitee).update({
    invitation,
    invitedBy,
    invitedAt: ts,
    updatedAt: ts,
  });
  return code;
};

export const getToken = async (
    firebase: app.App,
    code: string,
): Promise<string> => {
  const db = firebase.firestore();

  logger.info(`getToken: ${code}`);
  const inv = await db.collection("service").doc("conf").get();
  const invitation = calcInvitation(code, inv.get("seed"));
  const accounts = await db.collection("accounts")
      .where("invitation", "==", invitation).get();
  if (accounts.docs.length !== 1) {
    throw new Error("No record");
  }
  const account = accounts.docs[0];
  if (!account.get("invitedAt") || !account.get("invitedBy")) {
    await account.ref.update({
      invitation: null,
      invitedBy: null,
      invitedAt: null,
      updatedAt: new Date(),
    });
    throw new Error(
        `Invitation for account: ${account.id} has invalid status.`,
    );
  }
  const expired = new Date().getTime() - inv.get("invitationExpirationTime");
  if (account.get("invitedAt").toDate().getTime() < expired) {
    await account.ref.update({
      invitation: null,
      invitedBy: null,
      invitedAt: null,
      updatedAt: new Date(),
    });
    throw new Error(`Invitation for account: ${account.id} is expired.`);
  }
  const token = await firebase.auth().createCustomToken(account.id);
  logger.info(`Invited account: ${account.id} get token: ${token}`);
  return token;
};

export const onCreateAuthUser = async (
    firebase: app.App,
    user: auth.UserRecord,
): Promise<boolean> => {
  const db = firebase.firestore();
  const account = await db.collection("accounts").doc(user.uid).get();
  if (account.exists) {
    return true;
  }

  await firebase.auth().deleteUser(user.uid);
  logger.warn(`deleted: ${user.uid}`);
  return false;
};

export const onAccountUpdate = async (
    firebase: app.App,
    change: Change<firestore.DocumentSnapshot>,
): Promise<void> => {
  const {before, after} = change;
  if ((before.get("name") || null) !== (after.get("name") || null)) {
    await firebase.auth().updateUser(
        after.id,
        {displayName: after.get("name") || null},
    );
  }
  if ((before.get("email") || null) !== (after.get("email") || null)) {
    await firebase.auth().updateUser(
        after.id,
        {email: after.get("email") || null},
    );
  }
};
