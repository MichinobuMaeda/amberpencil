import {app, firestore, auth} from "firebase-admin";
import functionTest from "firebase-functions-test";
import {createHash} from "crypto";

global.console.log = jest.fn();
global.console.info = jest.fn();
global.console.warn = jest.fn();
global.console.error = jest.fn();

export type ColRef = firestore.CollectionReference;
export type QueryRef = firestore.Query<firestore.DocumentData>;
export type QuerySnap = firestore.QuerySnapshot;
export type DocRef = firestore.DocumentReference;
export type DocSnap = firestore.DocumentSnapshot<firestore.DocumentData>;

const test = functionTest();

export const sysNotExist = test.firestore.makeDocumentSnapshot(
    {},
    "document/service/sys",
);
export const sysData = {
  version: "1.0.0",
  url: "https://example.com",
  createdAt: new Date("2020-01-01T01:23:45.678Z"),
  updatedAt: new Date("2021-01-01T00:11:22.333Z"),
};
export const sysSnapshot = test.firestore.makeDocumentSnapshot(
    sysData,
    "document/service/sys",
);

export const invNotExist = test.firestore.makeDocumentSnapshot(
    {},
    "document/service/inv",
);
export const invData = {
  seed: "test seed",
  invitationExpirationTime: 3 * 24 * 3600 * 1000,
  createdAt: new Date("2020-01-01T01:23:45.678Z"),
  updatedAt: new Date("2021-01-01T00:11:22.333Z"),
};
export const invSnapshot = test.firestore.makeDocumentSnapshot(
    invData,
    "document/service/inv",
);

export const mockGet = jest.fn();
export const mockSet = jest.fn();
export const mockUpdate = jest.fn();
export const mockDocRef: Partial<DocRef> = {
  get: mockGet,
  set: mockSet,
  update: mockUpdate,
};
export const mockDoc = jest.fn(() => mockDocRef as DocRef);
export const mockAdd = jest.fn();
export const mockQueryGet = jest.fn();
export const mockQueryRef: Partial<QueryRef> = {
  get: mockQueryGet,
};
export const mockWhere = jest.fn(() => mockQueryRef as QueryRef);
export const mockCollectionRef: Partial<ColRef> = {
  doc: mockDoc,
  add: mockAdd,
  get: mockQueryGet,
  where: mockWhere,
};
export const mockCollection = jest.fn(() => mockCollectionRef as ColRef);
export const mockDb: Partial<firestore.Firestore> = {
  collection: mockCollection,
};

export const mockCreateUser = jest.fn();
export const mockUpdateUser = jest.fn();
export const mockDeleteUser = jest.fn();
export const mockCreateCustomToken = jest.fn();
export const mockAuth: Partial<auth.Auth> = {
  createUser: mockCreateUser,
  updateUser: mockUpdateUser,
  deleteUser: mockDeleteUser,
  createCustomToken: mockCreateCustomToken,
};
const partialFirebase: Partial<app.App> = {
  firestore: jest.fn(() => mockDb as firestore.Firestore),
  auth: jest.fn(() => mockAuth as auth.Auth),
};

export const mockFirebase = partialFirebase as app.App;

export const accountNotExist = test.firestore.makeDocumentSnapshot(
    {},
    "document/accounts/dummy",
);
export const invalidData = {
  valid: false,
  name: "Invalid User",
  admin: false,
  createdAt: new Date("2020-01-01T01:23:45.678Z"),
  updatedAt: new Date("2021-01-01T00:11:22.333Z"),
};
export const invalidSnapshot = test.firestore.makeDocumentSnapshot(
    invalidData,
    "document/accounts/invalid",
);
export const deletedData = {
  valid: true,
  name: "Deleted User",
  admin: false,
  createdAt: new Date("2020-01-01T01:23:45.678Z"),
  updatedAt: new Date("2021-01-01T00:11:22.333Z"),
  deletedAt: new Date("2022-01-01T00:11:22.333Z"),
};
export const deletedSnapshot = test.firestore.makeDocumentSnapshot(
    deletedData,
    "document/accounts/deleted",
);
export const user01Data = {
  valid: true,
  name: "User 01",
  admin: false,
  createdAt: new Date("2020-01-01T01:23:45.678Z"),
  updatedAt: new Date("2021-01-01T00:11:22.333Z"),
};
export const user01Snapshot = test.firestore.makeDocumentSnapshot(
    user01Data,
    "document/accounts/user01",
);
export const adminData = {
  valid: true,
  name: "User 01",
  admin: true,
  createdAt: new Date("2020-01-01T01:23:45.678Z"),
  updatedAt: new Date("2021-01-01T00:11:22.333Z"),
};
export const adminSnapshot = test.firestore.makeDocumentSnapshot(
    adminData,
    "document/accounts/admin",
);

export const testInvitation = (
    code: string,
    seed: string,
): string => {
  const hash = createHash("sha256");
  hash.update(code);
  hash.update(seed);
  return hash.digest("hex");
};

// export const mockGet = jest.fn();
// export const mockAdd = jest.fn();
// export const mockSet = jest.fn();
// export const mockUpdate = jest.fn();

// export const createUser = jest.fn();
// export const updateUser = jest.fn();
// export const deleteUser = jest.fn();
// export const createCustomToken = jest.fn();

// export const getMockFirebase = (): jest.Mocked<admin.app.App> => {
//   mockAdd.mockImplementation(() => new Promise((resolve) => {
//     resolve({id: "created"});
//   }));
//   mockSet.mockImplementation(() => new Promise((resolve) => {
//     resolve({});
//   }));
//   mockUpdate.mockImplementation(() => new Promise((resolve) => {
//     resolve({});
//   }));
//   createUser.mockImplementation(() => new Promise((resolve) => {
//     resolve({uid: "created"});
//   }));
//   updateUser.mockImplementation(() => new Promise((resolve) => {
//     resolve({});
//   }));
//   deleteUser.mockImplementation(() => new Promise((resolve) => {
//     resolve({});
//   }));
//   createCustomToken.mockImplementation(() => new Promise((resolve) => {
//     resolve("test token");
//   }));

//   mockFirebase.firestore.mockImplementation(() => ({
//     collection: (collection: string) => ({
//       add: (data: any) => mockAdd({collection, data}),
//       doc: (id: string) => ({
//         get: () => mockGet({collection, id}),
//         set: (data: any) => mockSet({collection, id, data}),
//         update: (data: any) => mockUpdate({collection, id, data}),
//       }),
//       where: (op1: any, op2: any, op3: any) => ({
//         get: () => mockGet({
//           collection, op1, op2, op3,
//         }),
//       }),
//       get: () => mockGet({collection}),
//     }),
//   }));

//   return {
//     firestore: () => ({
//       collection: (collection: string) => ({
//         add: (data: any) => mockAdd({collection, data}),
//         doc: (id: string) => ({
//           get: () => mockGet({collection, id}),
//           set: (data: any) => mockSet({collection, id, data}),
//           update: (data: any) => mockUpdate({collection, id, data}),
//         }),
//         where: (op1: any, op2: any, op3: any) => ({
//           get: () => mockGet({
//             collection, op1, op2, op3,
//           }),
//         }),
//         get: () => mockGet({collection}),
//       }),
//     }),
//     auth: () => ({
//       createUser,
//       updateUser,
//       deleteUser,
//       createCustomToken,
//     }),
//   };
// };
