import functionTest from "firebase-functions-test";

import {
  adminSnapshot,
} from "./testSetup";
import {
  createAuthUser,
  setUserPassword,
  onCreateAuthUser,
  onUpdateAccount,
} from "./index";

import * as users from "./users";
import * as guard from "./guard";

jest.mock("./users");
const mockedUsers = users as jest.Mocked<typeof users>;

jest.mock("./guard");
const mockedGuard = guard as jest.Mocked<typeof guard>;

const test = functionTest();

const wrappedCreateAuthUser = test.wrap(createAuthUser);
const wrappedSetUserPassword = test.wrap(setUserPassword);
const wrappedOnCreateAuthUser = test.wrap(onCreateAuthUser);
const wrappedOnUpdateAccount = test.wrap(onUpdateAccount);

beforeEach(() => {
  jest.clearAllMocks();
});

describe("createAuthUser", () => {
  it("calls adminUser() and users.createAuthUser().", async () => {
    const uid = adminSnapshot.id;
    mockedGuard.adminUser.mockImplementationOnce(
        () => Promise.resolve(adminSnapshot)
    );
    const data = {
      name: "User 02",
      admin: false,
      tester: true,
    };
    await wrappedCreateAuthUser(data, {auth: {uid}});
    expect(mockedGuard.adminUser.mock.calls).toEqual([
      [expect.any(Object), uid],
    ]);
    expect(mockedUsers.createAuthUser.mock.calls).toEqual([
      [expect.any(Object), data],
    ]);
  });

  it("rejects adminUser() throws error: 'not admin'.", async () =>{
    const uid = adminSnapshot.id;
    mockedGuard.adminUser.mockImplementationOnce(
        () => {
          throw new Error(`User: ${uid} is not admin.`);
        }
    );
    const data = {
      name: "User 02",
      admin: false,
      tester: true,
    };
    await expect(wrappedCreateAuthUser(data, {auth: {uid}})).rejects.toThrow();
    expect(mockedGuard.adminUser.mock.calls).toEqual([
      [expect.any(Object), uid],
    ]);
    expect(mockedUsers.createAuthUser.mock.calls).toEqual([]);
  });

  it("rejects adminUser() throws error: no auth.", async () =>{
    mockedGuard.adminUser.mockImplementationOnce(
        () => {
          throw new Error("Param uid is missing.");
        }
    );
    const data = {
      name: "User 02",
      admin: false,
      tester: true,
    };
    await expect(wrappedCreateAuthUser(data, {})).rejects.toThrow();
    expect(mockedGuard.adminUser.mock.calls).toEqual([
      [expect.any(Object), ""],
    ]);
    expect(mockedUsers.createAuthUser.mock.calls).toEqual([]);
  });
});

describe("setUserPassword", () => {
  it("calls adminUser() and users.setUserPassword().", async () => {
    const uid = adminSnapshot.id;
    mockedGuard.adminUser.mockImplementationOnce(
        () => Promise.resolve(adminSnapshot)
    );
    const data = {
      name: "User 02",
      admin: false,
      tester: true,
    };
    await wrappedSetUserPassword(data, {auth: {uid}});
    expect(mockedGuard.adminUser.mock.calls).toEqual([
      [expect.any(Object), uid],
    ]);
    expect(mockedUsers.setUserPassword.mock.calls).toEqual([
      [expect.any(Object), data],
    ]);
  });

  it("rejects if adminUser() throws error: 'not admin'.", async () =>{
    const uid = adminSnapshot.id;
    mockedGuard.adminUser.mockImplementationOnce(
        () => {
          throw new Error(`User: ${uid} is not admin.`);
        }
    );
    const data = {
      name: "User 02",
      admin: false,
      tester: true,
    };
    await expect(wrappedSetUserPassword(data, {auth: {uid}})).rejects.toThrow();
    expect(mockedGuard.adminUser.mock.calls).toEqual([
      [expect.any(Object), uid],
    ]);
    expect(mockedUsers.setUserPassword.mock.calls).toEqual([]);
  });

  it("rejects adminUser() throws error: no auth.", async () =>{
    mockedGuard.adminUser.mockImplementationOnce(
        () => {
          throw new Error("Param uid is missing.");
        }
    );
    const data = {
      name: "User 02",
      admin: false,
      tester: true,
    };
    await expect(wrappedSetUserPassword(data, {})).rejects.toThrow();
    expect(mockedGuard.adminUser.mock.calls).toEqual([
      [expect.any(Object), ""],
    ]);
    expect(mockedUsers.setUserPassword.mock.calls).toEqual([]);
  });
});

describe("onCreateAuthUser", () => {
  it("calls users.onCreateAuthUser().", async () => {
    const data = {uid: "user01"};
    await wrappedOnCreateAuthUser({uid: "user01"});
    expect(mockedUsers.onCreateAuthUser.mock.calls).toEqual([
      [expect.any(Object), data],
    ]);
  });
});

describe("onCreateAuthUser", () => {
  it("calls users.onCreateAuthUser().", async () => {
    const data = {uid: "user01"};
    await wrappedOnCreateAuthUser(data);
    expect(mockedUsers.onCreateAuthUser.mock.calls).toEqual([
      [expect.any(Object), data],
    ]);
  });
});

describe("onUpdateAccount", () => {
  it("calls users.onAccountUpdate().", async () => {
    const data = {before: {}, after: {}};
    await wrappedOnUpdateAccount(data);
    expect(mockedUsers.onAccountUpdate.mock.calls).toEqual([
      [expect.any(Object), data],
    ]);
  });
});
