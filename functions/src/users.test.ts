import {auth, firestore} from "firebase-admin";
import functionTest from "firebase-functions-test";
import {
  confData,
  confSnapshot,
  accountNotExist,
  user01Snapshot,
  testInvitation,
  mockFirebase,
  mockGet,
  mockAdd,
  mockSet,
  mockUpdate,
  mockCollection,
  mockQueryGet,
  mockWhere,
  mockDoc,
  // mockGetUser,
  mockCreateUser,
  mockUpdateUser,
  mockDeleteUser,
  mockCreateCustomToken,
  DocSnap,
  DocRef,
  mockGetUser,
} from "./testSetup";
import {
  createAuthUser,
  setUserPassword,
  invite,
  getToken,
  onCreateAuthUser,
  onAccountUpdate,
} from "./users";

const test = functionTest();

beforeEach(() => {
  jest.clearAllMocks();
});

describe("createAuthUser()", () => {
  const name = "User 01";
  const group = "group01";
  const email = "account01@example.com";
  const password = "account01's password";

  it("rejects name with length 0.", async () => {
    await expect(createAuthUser(
        mockFirebase,
        {name: "", admin: false, tester: false},
    )).rejects.toThrow("Param name is missing.");
  });

  it("rejects email with length 0.", async () => {
    await expect(createAuthUser(
        mockFirebase,
        {
          name: "name", admin: false, tester: false,
          group: "group", email: "",
        },
    )).rejects.toThrow("Param email is empty.");
  });

  it("rejects password with length 0.", async () => {
    await expect(createAuthUser(
        mockFirebase,
        {
          name: "name", admin: false, tester: false,
          group: "group", email: "email", password: "",
        },
    )).rejects.toThrow("Param password is empty.");
  });

  it("creates account with given properties" +
  " and returns uid.", async () => {
    mockAdd.mockImplementationOnce(() =>Promise.resolve(user01Snapshot));

    expect(await createAuthUser(
        mockFirebase,
        {name, admin: false, tester: false},
    )).toEqual(user01Snapshot.id);
    expect(mockCollection.mock.calls).toEqual([
      ["accounts"],
      ["people"],
    ]);
    expect(mockAdd.mock.calls).toEqual([[{
      name,
      email: null,
      valid: true,
      admin: false,
      tester: false,
      group: null,
      themeMode: null,
      invitation: null,
      invitedBy: null,
      invitedAt: null,
      createdAt: expect.any(Date),
      updatedAt: expect.any(Date),
      deletedAt: null,
    }]]);
    expect(mockDoc.mock.calls).toEqual([
      [user01Snapshot.id],
    ]);
    expect(mockSet.mock.calls).toEqual([[{
      groups: [],
      createdAt: expect.any(Date),
      updatedAt: expect.any(Date),
      deletedAt: null,
    }]]);
    expect(mockCreateUser.mock.calls).toEqual([[{
      uid: user01Snapshot.id,
      displayName: name,
    }]]);
  });

  it("creates account with given properties inclueds group," +
  " and returns uid.", async () => {
    mockAdd.mockImplementationOnce(() =>Promise.resolve(user01Snapshot));

    expect(await createAuthUser(
        mockFirebase,
        {name, admin: false, tester: false, group},
    )).toEqual(user01Snapshot.id);
    expect(mockCollection.mock.calls).toEqual([
      ["accounts"],
      ["people"],
    ]);
    expect(mockAdd.mock.calls).toEqual([[{
      name,
      email: null,
      valid: true,
      admin: false,
      tester: false,
      group,
      themeMode: null,
      invitation: null,
      invitedBy: null,
      invitedAt: null,
      createdAt: expect.any(Date),
      updatedAt: expect.any(Date),
      deletedAt: null,
    }]]);
    expect(mockDoc.mock.calls).toEqual([
      [user01Snapshot.id],
    ]);
    expect(mockSet.mock.calls).toEqual([[{
      groups: [group],
      createdAt: expect.any(Date),
      updatedAt: expect.any(Date),
      deletedAt: null,
    }]]);
    expect(mockCreateUser.mock.calls).toEqual([[{
      uid: user01Snapshot.id,
      displayName: name,
    }]]);
  });

  it("creates account with given properties inclueds email," +
  " and returns uid.", async () => {
    mockAdd.mockImplementationOnce(() =>Promise.resolve(user01Snapshot));

    expect(await createAuthUser(
        mockFirebase,
        {name, admin: false, tester: false, group, email},
    )).toEqual(user01Snapshot.id);
    expect(mockCollection.mock.calls).toEqual([
      ["accounts"],
      ["people"],
    ]);
    expect(mockAdd.mock.calls).toEqual([[{
      name,
      email,
      valid: true,
      admin: false,
      tester: false,
      group,
      themeMode: null,
      invitation: null,
      invitedBy: null,
      invitedAt: null,
      createdAt: expect.any(Date),
      updatedAt: expect.any(Date),
      deletedAt: null,
    }]]);
    expect(mockDoc.mock.calls).toEqual([
      [user01Snapshot.id],
    ]);
    expect(mockSet.mock.calls).toEqual([[{
      groups: [group],
      createdAt: expect.any(Date),
      updatedAt: expect.any(Date),
      deletedAt: null,
    }]]);
    expect(mockCreateUser.mock.calls).toEqual([[{
      uid: user01Snapshot.id,
      displayName: name,
      email,
    }]]);
  });

  it("creates account with given properties inclueds password," +
  " and returns uid.", async () => {
    mockAdd.mockImplementationOnce(() =>Promise.resolve(user01Snapshot));

    expect(await createAuthUser(
        mockFirebase,
        {name, admin: false, tester: false, group, email, password},
    )).toEqual(user01Snapshot.id);
    expect(mockCollection.mock.calls).toEqual([
      ["accounts"],
      ["people"],
    ]);
    expect(mockAdd.mock.calls).toEqual([[{
      name,
      email,
      valid: true,
      admin: false,
      tester: false,
      group,
      themeMode: null,
      invitation: null,
      invitedBy: null,
      invitedAt: null,
      createdAt: expect.any(Date),
      updatedAt: expect.any(Date),
      deletedAt: null,
    }]]);
    expect(mockDoc.mock.calls).toEqual([
      [user01Snapshot.id],
    ]);
    expect(mockSet.mock.calls).toEqual([[{
      groups: [group],
      createdAt: expect.any(Date),
      updatedAt: expect.any(Date),
      deletedAt: null,
    }]]);
    expect(mockCreateUser.mock.calls).toEqual([[{
      uid: user01Snapshot.id,
      displayName: name,
      email,
      password,
    }]]);
  });
});

describe("setUserPassword()", () => {
  const uid = "id01";
  const password = "account01@example.com";

  it("rejects password with length 0.", async () => {
    await expect(
        setUserPassword(mockFirebase, {uid, password: ""})
    ).rejects.toThrow("Param password is empty.");
  });

  it("updates password of auth entry.", async () => {
    await setUserPassword(mockFirebase, {uid, password});
    expect(mockUpdateUser.mock.calls).toEqual([[uid, {password}]]);
  });
});

describe("invite()", () => {
  it("creates invitation code and" +
  " save hashed code, host account id and timestamp," +
  " and return invitation code.", async () => {
    mockGet.mockImplementationOnce(() => Promise.resolve(confSnapshot));

    const code = await invite(mockFirebase, "admin", "id01");

    expect(code.length).toBeGreaterThan(0);
    expect(mockCollection.mock.calls).toEqual([
      ["service"],
      ["accounts"],
    ]);
    expect(mockDoc.mock.calls).toEqual([
      ["conf"],
      ["id01"],
    ]);
    expect(mockUpdate.mock.calls).toEqual([[{
      invitation: testInvitation(code, "test seed"),
      invitedBy: "admin",
      invitedAt: expect.any(Date),
      updatedBy: null,
      updatedAt: expect.any(Date),
    }]]);
  });
});

describe("getToken()", () => {
  it("rejects invitation without record.", async () => {
    mockGet.mockImplementationOnce(() => Promise.resolve(confSnapshot));
    mockQueryGet.mockImplementationOnce(() => Promise.resolve({docs: []}));

    await expect(
        getToken(mockFirebase, "dummy code")
    ).rejects.toThrow("No record");

    expect(mockCollection.mock.calls).toEqual([
      ["service"],
      ["accounts"],
    ]);
    expect(mockDoc.mock.calls).toEqual([["conf"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
    expect(mockWhere.mock.calls).toEqual([
      ["invitation", "==", testInvitation("dummy code", confData.seed)],
    ]);
    expect(mockUpdate.mock.calls).toEqual([]);
  });

  it("rejects invitation without invitedBy.", async () => {
    const invitation = testInvitation("test code", "test seed");
    const invitedAt = new firestore.Timestamp(
        (Math.floor(new Date().getTime() / 1000)), 0);
    const mockInvitedRef: Partial<DocRef> = {update: mockUpdate};
    const mockInvited: Partial<DocSnap> = {
      id: "user01",
      get: (key) => {
        switch (key) {
          case "invitedAt": return invitedAt;
          case "invitedBy": return undefined;
          case "invitation": return invitation;
          default: return undefined;
        }
      },
      ref: mockInvitedRef as DocRef,
    };
    mockGet.mockImplementationOnce(() => Promise.resolve(confSnapshot));
    mockQueryGet.mockImplementationOnce(
        () => Promise.resolve({docs: [mockInvited]})
    );

    await expect(
        getToken(mockFirebase, "test code")
    ).rejects.toThrow("Invitation for account: user01 has invalid status.");

    expect(mockCollection.mock.calls).toEqual([
      ["service"],
      ["accounts"],
    ]);
    expect(mockDoc.mock.calls).toEqual([["conf"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
    expect(mockWhere.mock.calls).toEqual([
      ["invitation", "==", testInvitation("test code", "test seed")],
    ]);
    expect(mockUpdate.mock.calls).toEqual([[{
      invitation: null,
      invitedBy: null,
      invitedAt: null,
      updatedBy: null,
      updatedAt: expect.any(Date),
    }]]);
  });

  it("rejects invitation without invitedAt.", async () => {
    const invitation = testInvitation("test code", "test seed");
    const mockInvitedRef: Partial<DocRef> = {update: mockUpdate};
    const mockInvited: Partial<DocSnap> = {
      id: "user01",
      exists: true,
      get: (key) => {
        switch (key) {
          case "invitedAt": return undefined;
          case "invitedBy": return "admin";
          case "invitation": return invitation;
          default: return undefined;
        }
      },
      ref: mockInvitedRef as DocRef,
    };
    mockGet.mockImplementationOnce(() => Promise.resolve(confSnapshot));
    mockQueryGet.mockImplementationOnce(
        () => Promise.resolve({docs: [mockInvited]})
    );

    await expect(
        getToken(mockFirebase, "test code")
    ).rejects.toThrow("Invitation for account: user01 has invalid status.");

    expect(mockCollection.mock.calls).toEqual([
      ["service"],
      ["accounts"],
    ]);
    expect(mockDoc.mock.calls).toEqual([["conf"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
    expect(mockWhere.mock.calls).toEqual([
      ["invitation", "==", testInvitation("test code", "test seed")],
    ]);
    expect(mockUpdate.mock.calls).toEqual([[{
      invitation: null,
      invitedBy: null,
      invitedAt: null,
      updatedBy: null,
      updatedAt: expect.any(Date),
    }]]);
  });

  it("rejects invitation with expired timestamp.", async () => {
    const invitation = testInvitation("test code", "test seed");
    const invitedAt = new firestore.Timestamp(
        (Math.floor((
          new Date().getTime() - confData.invitationExpirationTime) / 1000
        ) - 1), 0);
    const mockInvitedRef: Partial<DocRef> = {update: mockUpdate};
    const mockInvited: Partial<DocSnap> = {
      id: "user01",
      get: (key) => {
        switch (key) {
          case "invitedAt": return invitedAt;
          case "invitedBy": return "admin";
          case "invitation": return invitation;
          default: return undefined;
        }
      },
      ref: mockInvitedRef as DocRef,
    };
    mockGet.mockImplementationOnce(() => Promise.resolve(confSnapshot));
    mockQueryGet.mockImplementationOnce(
        () => Promise.resolve({docs: [mockInvited]})
    );

    await expect(getToken(mockFirebase, "test code"))
        .rejects.toThrow("Invitation for account: user01 is expired.");

    expect(mockCollection.mock.calls).toEqual([
      ["service"],
      ["accounts"],
    ]);
    expect(mockDoc.mock.calls).toEqual([["conf"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
    expect(mockWhere.mock.calls).toEqual([
      ["invitation", "==", testInvitation("test code", "test seed")],
    ]);
    expect(mockUpdate.mock.calls).toEqual([[{
      invitation: null,
      invitedBy: null,
      invitedAt: null,
      updatedBy: null,
      updatedAt: expect.any(Date),
    }]]);
  });

  it("returns token.", async () => {
    const invitation = testInvitation("test code", "test seed");
    const invitedAt = new firestore.Timestamp(
        (Math.floor((
          new Date().getTime() - confData.invitationExpirationTime) / 1000
        ) + 1), 0);
    const mockInvitedRef: Partial<DocRef> = {update: mockUpdate};
    const mockInvited: Partial<DocSnap> = {
      id: "user01",
      get: (key) => {
        switch (key) {
          case "invitedAt": return invitedAt;
          case "invitedBy": return "admin";
          case "invitation": return invitation;
          default: return undefined;
        }
      },
      ref: mockInvitedRef as DocRef,
    };
    mockGet.mockImplementationOnce(() => Promise.resolve(confSnapshot));
    mockQueryGet.mockImplementationOnce(
        () => Promise.resolve({docs: [mockInvited]})
    );
    mockCreateCustomToken.mockImplementationOnce(() => "test token");

    const token = await getToken(mockFirebase, "test code");
    expect(token).toEqual("test token");
  });
});

describe("onCreateAuthUser()", () => {
  it("delete user without its account doc.", async () => {
    mockGet.mockImplementationOnce(() => Promise.resolve(accountNotExist));

    await onCreateAuthUser(
        mockFirebase,
        {uid: accountNotExist.id} as auth.UserRecord,
    );

    expect(mockDeleteUser.mock.calls).toEqual([[accountNotExist.id]]);
  });

  it("do nothing in all other cases.", async () => {
    mockGet.mockImplementationOnce(() => Promise.resolve(user01Snapshot));

    await onCreateAuthUser(
        mockFirebase,
        {uid: user01Snapshot.id} as auth.UserRecord,
    );

    expect(mockDeleteUser.mock.calls).toEqual([]);
  });
});

describe("onAccountUpdate()", () => {
  it("update displayName of its auth user " +
  "on change the name of the account", async () => {
    await onAccountUpdate(
        mockFirebase,
        {
          before: test.firestore.makeDocumentSnapshot(
              {name: "Name before"},
              "document/accounts/user01",
          ),
          after: test.firestore.makeDocumentSnapshot(
              {name: "Name after"},
              "document/accounts/user01",
          ),
        },
    );

    await onAccountUpdate(
        mockFirebase,
        {
          before: test.firestore.makeDocumentSnapshot(
              {name: null},
              "document/accounts/user01",
          ),
          after: test.firestore.makeDocumentSnapshot(
              {name: "Name after"},
              "document/accounts/user01",
          ),
        },
    );

    await onAccountUpdate(
        mockFirebase,
        {
          before: test.firestore.makeDocumentSnapshot(
              {name: "Name before"},
              "document/accounts/user01",
          ),
          after: test.firestore.makeDocumentSnapshot(
              {name: null},
              "document/accounts/user01",
          ),
        },
    );

    expect(mockUpdateUser.mock.calls).toEqual([
      ["user01", {displayName: "Name after"}],
      ["user01", {displayName: "Name after"}],
      ["user01", {displayName: null}],
    ]);
  });

  it("update email as same as auth user " +
  "on change the any thinf of the account", async () => {
    const user01: Partial<auth.UserInfo> = {email: "Email before"};
    const user02: Partial<auth.UserInfo> = {email: "Email after"};
    mockGetUser
        .mockImplementationOnce(() => null)
        .mockImplementationOnce(() => user01)
        .mockImplementationOnce(() => user02)
        .mockImplementationOnce(() => user01)
        .mockImplementationOnce(() => user01);

    await onAccountUpdate(
        mockFirebase,
        {
          before: test.firestore.makeDocumentSnapshot(
              {email: "Email before"},
              "document/accounts/user01",
          ),
          after: test.firestore.makeDocumentSnapshot(
              {email: "Email after"},
              "document/accounts/user01",
          ),
        },
    );

    await onAccountUpdate(
        mockFirebase,
        {
          before: test.firestore.makeDocumentSnapshot(
              {email: "Email before"},
              "document/accounts/user01",
          ),
          after: test.firestore.makeDocumentSnapshot(
              {email: "Email after"},
              "document/accounts/user01",
          ),
        },
    );

    await onAccountUpdate(
        mockFirebase,
        {
          before: test.firestore.makeDocumentSnapshot(
              {email: "Email before"},
              "document/accounts/user01",
          ),
          after: test.firestore.makeDocumentSnapshot(
              {email: "Email after"},
              "document/accounts/user01",
          ),
        },
    );

    await onAccountUpdate(
        mockFirebase,
        {
          before: test.firestore.makeDocumentSnapshot(
              {name: "Name before", email: null},
              "document/accounts/user01",
          ),
          after: test.firestore.makeDocumentSnapshot(
              {name: "Name after", email: null},
              "document/accounts/user01",
          ),
        },
    );

    await onAccountUpdate(
        mockFirebase,
        {
          before: test.firestore.makeDocumentSnapshot(
              {name: "Name before", email: "Email old"},
              "document/accounts/user01",
          ),
          after: test.firestore.makeDocumentSnapshot(
              {name: "Name after", email: "Email old"},
              "document/accounts/user01",
          ),
        },
    );

    expect(mockUpdate.mock.calls).toEqual([
      [
        {
          email: null,
          updatedBy: null,
          updatedAt: expect.any(Date),
        },
      ],
      [
        {
          email: "Email before",
          updatedBy: null,
          updatedAt: expect.any(Date),
        },
      ],
      [
        {
          email: "Email before",
          updatedBy: null,
          updatedAt: expect.any(Date),
        },
      ],
      [
        {
          email: "Email before",
          updatedBy: null,
          updatedAt: expect.any(Date),
        },
      ]]);
  });

  it("do nothing in all other cases.", async () => {
    await onAccountUpdate(
        mockFirebase,
        {
          before: test.firestore.makeDocumentSnapshot(
              {group: "Group before"},
              "document/accounts/user01",
          ),
          after: test.firestore.makeDocumentSnapshot(
              {group: "Group after"},
              "document/accounts/user01",
          ),
        },
    );

    expect(mockUpdateUser.mock.calls).toEqual([]);
  });
});
