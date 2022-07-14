const functions = require("firebase-functions");
const firebase = require("./firebase");
const deploymentFunc = require("./deployment");
const {requireAdminAccount} = require("./guard");
const accounts = require("./accounts");

const deployment = functions.region(functions.config().region)
    .firestore.document("service/deployment")
    .onDelete(
        (snap) => deploymentFunc(firebase, snap),
    );

const onCreateAccount = functions.region(functions.config().region)
    .firestore.document("accounts/{accountId}").onCreate(
        (doc) => accounts.onCreateAccount(firebase, doc),
    );

const onUpdateAccount = functions.region(functions.config().region)
    .firestore.document("accounts/{accountId}").onUpdate(
        (chane) => accounts.onUpdateAccount(firebase, chane),
    );

const invite = functions.region(functions.config().region)
    .https.onCall(function(data, context) {
      return requireAdminAccount(
          firebase,
          context.auth?.uid,
          accounts.invite(data),
      );
    });

const getToken = functions.region(functions.config().region).https.onCall(
    (data) => accounts.getToken(firebase, data),
);

module.exports = {
  deployment,
  onCreateAccount,
  onUpdateAccount,
  invite,
  getToken,
};
