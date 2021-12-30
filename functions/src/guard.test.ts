import {
  accountNotExist,
  invalidSnapshot,
  deletedSnapshot,
  user01Snapshot,
  adminSnapshot,
  mockCollection,
  mockDoc,
  mockGet,
  mockFirebase,
} from "./setupTests";
import {
  validUser,
  adminUser,
} from "./guard";

beforeEach(() => {
  jest.clearAllMocks();
});

describe("validUser()", () => {
  it("rejects undefined uid.", async () => {
    await expect(
        validUser(mockFirebase, "")
    ).rejects.toThrow("Param uid is missing.");
    expect(mockCollection.mock.calls).toEqual([]);
    expect(mockDoc.mock.calls).toEqual([]);
    expect(mockGet.mock.calls).toEqual([]);
  });

  it("rejects uid without doc.", async () => {
    mockGet.mockImplementationOnce(() => Promise.resolve(accountNotExist));

    await expect(
        validUser(mockFirebase, "dummy")
    ).rejects.toThrow("User: dummy is not exists.");
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["dummy"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });

  it("rejects invalidUser account.", async () => {
    mockGet.mockImplementationOnce(() =>Promise.resolve(invalidSnapshot));

    await expect(
        validUser(mockFirebase, "invalid")
    ).rejects.toThrow("User: invalid is not valid.");
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["invalid"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });

  it("rejects deleted account.", async () => {
    mockGet.mockImplementationOnce(() =>Promise.resolve(deletedSnapshot));

    await expect(
        validUser(mockFirebase, "deleted")
    ).rejects.toThrow("User: deleted has deleted.");
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["deleted"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });

  it("returns valid account without adminUser priv.", async () => {
    mockGet.mockImplementationOnce(() =>Promise.resolve(user01Snapshot));

    expect(
        await validUser(mockFirebase, "user01")
    ).toEqual(user01Snapshot);
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["user01"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });

  it("returns admin account.", async () => {
    mockGet.mockImplementationOnce(() =>Promise.resolve(adminSnapshot));

    expect(
        await validUser(mockFirebase, "admin")
    ).toEqual(adminSnapshot);
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["admin"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });
});

describe("adminUser()", () => {
  it("rejects undefined uid.", async () => {
    await expect(
        adminUser(mockFirebase, "")
    ).rejects.toThrow("Param uid is missing.");
    expect(mockCollection.mock.calls).toEqual([]);
    expect(mockDoc.mock.calls).toEqual([]);
    expect(mockGet.mock.calls).toEqual([]);
  });

  it("rejects uid without doc.", async () => {
    mockGet.mockImplementationOnce(() => Promise.resolve(accountNotExist));

    await expect(
        adminUser(mockFirebase, "dummy")
    ).rejects.toThrow("User: dummy is not exists.");
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["dummy"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });

  it("rejects invalid account.", async () => {
    mockGet.mockImplementationOnce(() =>Promise.resolve(invalidSnapshot));

    await expect(
        adminUser(mockFirebase, "invalid")
    ).rejects.toThrow("User: invalid is not valid.");
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["invalid"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });

  it("rejects deleted account.", async () => {
    mockGet.mockImplementationOnce(() =>Promise.resolve(deletedSnapshot));

    await expect(
        adminUser(mockFirebase, "deleted")
    ).rejects.toThrow("User: deleted has deleted.");
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["deleted"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });

  it("rejects valid account without adminUser priv.", async () => {
    mockGet.mockImplementationOnce(() =>Promise.resolve(user01Snapshot));

    await expect(
        adminUser(mockFirebase, "user01")
    ).rejects.toThrow("User: user01 is not admin.");
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["user01"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });

  it("returns valid account with admin priv.", async () => {
    mockGet.mockImplementationOnce(() =>Promise.resolve(adminSnapshot));

    expect(
        await adminUser(mockFirebase, "admin")
    ).toEqual(adminSnapshot);
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockDoc.mock.calls).toEqual([["admin"]]);
    expect(mockGet.mock.calls).toEqual([[]]);
  });
});
