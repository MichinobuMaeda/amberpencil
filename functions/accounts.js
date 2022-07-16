const EMPTY_EMAIL = "unknown@domain.invalid";

/**
 * Handle firestore event: created doc of collection 'accoutns'.
 * @param {object} firebase Firebase API
 * @param {object} doc the created doc.
 * @return {Promise} void
 */
async function onCreateAccount(firebase, doc) {
  const displayName = doc.get("name") || "";
  const email = doc.get("email");

  const auth = firebase.auth();
  let user;

  if (email) {
    try {
      user = await auth.getUserByEmail(email);
      await auth.updateUser(user.uid, {displayName});
    } catch (e) {
      user = await auth.createUser({uid: doc.id, displayName, email});
    }
  } else {
    user = await auth.createUser({uid: doc.id, displayName});
  }

  await doc.ref.update({
    uid: user.uid,
    updatedAt: new Date(),
  });
}

/**
 * Handle firestore event: updated doc of collection 'accoutns'.
 * @param {object} firebase Firebase API
 * @param {object} change the updated doc
 * @return {Promise} void
 */
const onUpdateAccount = async (firebase, {after}) => {
  const uid = after.get("uid");

  if (uid) {
    const auth = firebase.auth();
    const user = await auth.getUser(uid);

    // Firebase auth has no method to remove email of users.
    if ((user.email || EMPTY_EMAIL) !== (after.get("email") || EMPTY_EMAIL)) {
      await auth.updateUser(uid, {
        email: after.get("email") || EMPTY_EMAIL,
        emailVerified: false,
      });
    }

    if ((user.displayName || "") !== (after.get("name") || "")) {
      await auth.updateUser(uid, {displayName: after.get("name") || ""});
    }
  } else {
    await onCreateAccount(firebase, after);
  }
};

/**
 * Get hash of the invitation code with seed.
 * @param {string} seed the seed for hash
 * @param {string} code the invitation code
 * @return {striing} hashed invitation code
 */
async function hashInvitation(seed, code) {
  const {createHash} = await require("node:crypto");
  const hash = createHash("sha256");
  hash.update(seed);
  hash.update(code);
  return hash.digest("hex");
}

/**
 * Create invitation code.
 * @param {object} request the request parameter: invited user id
 * @return {function} the function for invited user
 */
function invite({invitee}) {
  return async function(firebase, uid) {
    const db = firebase.firestore();
    const conf = await db.collection("service").doc("conf").get();
    const {randomBytes} = await require("node:crypto");
    const code = randomBytes(128).toString("hex");
    const ts = new Date();

    await db
        .collection("accounts")
        .doc(invitee)
        .update({
          invitation: await hashInvitation(conf.get("seed") || "", code),
          invitedBy: uid,
          invitedAt: ts,
          updatedBy: uid,
          updatedAt: ts,
        });

    return code;
  };
}

/**
 * Get authentication token from invitation code.
 * @param {object} firebase Firebase API
 * @param {object} request the request parameter: invitation code
 * @return {string} authentication token
 */
async function getToken(firebase, {code}) {
  const db = firebase.firestore();
  const conf = await db.collection("service").doc("conf").get();
  const invitation = await hashInvitation(`${conf.get("seed")}`, code);
  const accounts = await db
      .collection("accounts")
      .where("invitation", "==", invitation)
      .get();

  if (accounts.docs.length !== 1) {
    throw new Error("No record");
  }

  const account = accounts.docs[0];
  const resetRecord = {
    invitation: null,
    invitedBy: null,
    invitedAt: null,
    updatedBy: "system",
    updatedAt: new Date(),
  };

  const empties = ["uid", "invitedAt", "invitedBy"].filter(
      (key) => !account.get(key),
  );

  if (empties.length) {
    await account.ref.update(resetRecord);
    throw new Error(`Invalid status: ${account.id} ${empties.join(", ")}`);
  }

  const expired = new Date().getTime() - conf.get("invExp");
  const invitedAt = account.get("invitedAt").toMillis();

  if (invitedAt < expired) {
    await account.ref.update(resetRecord);
    throw new Error(`Expired: ${account.id}`);
  }

  return firebase.auth().createCustomToken(account.get("uid"));
}

module.exports = {
  onCreateAccount,
  onUpdateAccount,
  hashInvitation,
  invite,
  getToken,
};
