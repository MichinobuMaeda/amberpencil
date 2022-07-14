const functions = require("firebase-functions");

const firebase = require("./firebase");
const deployment = require("./deployment");

const setTestData = functions.region(
    functions.config().region,
).https.onRequest(
    async (req, res) => {
      const db = firebase.firestore();
      const ref = db.collection("service").doc("deployment");
      await ref.set({
        version: 0,
        updatedAt: new Date(),
      });

      await deployment(firebase, await ref.get());
      res.send("OK\n");
    },
);

const clearAll = async function() {
  const auth = firebase.auth();
  const userList = await auth.listUsers();
  await Promise.all(
      (userList.users || []).map(
          (user) => auth.deleteUser(user.uid),
      ),
  );

  const db = firebase.firestore();
  const batch = db.batch();
  const cols = await db.listCollections();
  await Promise.all(
      cols.map(
          (col) => col.get().then(
              (snap) => snap.forEach(
                  (doc) => batch.delete(doc.ref),
              ),
          ),
      ),
  );
  await batch.commit();
};

module.exports = {
  setTestData,
  clearAll,
};
