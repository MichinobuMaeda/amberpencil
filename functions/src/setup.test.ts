import functionTest from "firebase-functions-test";
import axios from "axios";
import {
  DocRef,
  DocSnap,
  sysNotExist,
  sysData,
  mockGet,
  mockSet,
  mockUpdate,
  mockCollection,
  mockQueryGet,
  mockFirebase,
  mockDoc,
} from "./testSetup";
import * as users from "./users";
import {
  getSys,
  updateVersion,
  updateData,
  install,
} from "./setup";

const test = functionTest();

jest.mock("axios");
const mockedAxios = axios as jest.Mocked<typeof axios>;

jest.mock("./users");
const mockedUsers = users as jest.Mocked<typeof users>;

const mockSysRef: Partial<DocRef> = {update: mockUpdate};
const sysSnapshot: Partial<DocSnap> = {
  id: "sys",
  exists: true,
  get: (key) => {
    switch (key) {
      case "version": return sysData.version;
      case "url": return sysData.url;
      case "createdAt": return sysData.createdAt;
      case "updatedAt": return sysData.updatedAt;
      default: return undefined;
    }
  },
  ref: mockSysRef as DocRef,
};

beforeEach(() => {
  jest.clearAllMocks();
});

describe("getSys()", () => {
  it("returns null if document \"sys\" is not exists.", async () => {
    mockGet
        .mockImplementationOnce(() => new Promise((resolve) => {
          resolve(sysNotExist);
        }));
    const sys = await getSys(mockFirebase);
    expect(sys).toBeNull();
  });

  it("returns document \"sys\" if document \"sys\" is exists.", async () => {
    mockGet
        .mockImplementationOnce(() => new Promise((resolve) => {
          resolve(sysSnapshot as DocSnap);
        }));
    const sys = await getSys(mockFirebase);
    expect(sys).toEqual(sysSnapshot);
  });
});

describe("updateVersion()", () => {
  it("returns false and not modifies conf has same version.", async () => {
    mockedAxios.get.mockResolvedValue({
      data: {version: sysData.version},
    });

    expect(
        await updateVersion(sysSnapshot as DocSnap, mockedAxios)
    ).toBeFalsy();
    expect(mockUpdate.mock.calls).toEqual([]);
  });

  it("returns true and update conf has old version.", async () => {
    mockedAxios.get.mockResolvedValue({
      data: {version: "1.0.1"},
    });
    expect(
        await updateVersion(sysSnapshot as DocSnap, mockedAxios)
    ).toBeTruthy();
    expect(mockUpdate.mock.calls).toEqual([[{
      version: "1.0.1",
      updatedAt: expect.any(Date),
    }]]);
  });
});

describe("updateData()", () => {
  const latestDataVersion = 1;
  const mockAccountRef: Partial<DocRef> = {update: mockUpdate};
  const user01Snapshot: Partial<DocSnap> = {
    id: "user01",
    exists: true,
    get: () => undefined,
    ref: mockAccountRef as DocRef,
  };
  const adminSnapshot: Partial<DocSnap> = {
    id: "admin",
    exists: true,
    get: () => undefined,
    ref: mockAccountRef as DocRef,
  };

  it("proc data update from the current data version" +
  " to the latest data version " +
  "and set dataVsersion.", async () => {
    mockQueryGet.mockImplementationOnce(() => Promise.resolve(
        {docs: [user01Snapshot, adminSnapshot]}
    ));

    await updateData(mockFirebase, sysSnapshot as DocSnap);
    expect(mockCollection.mock.calls).toEqual([["accounts"]]);
    expect(mockQueryGet.mock.calls).toEqual([[]]);
    expect(mockUpdate.mock.calls).toEqual([
      [
        {
          themeMode: 0,
          updatedAt: expect.any(Date),
        },
      ],
      [
        {
          themeMode: 0,
          updatedAt: expect.any(Date),
        },
      ],
      [
        {
          dataVersion: 1,
          updatedAt: expect.any(Date),
        },
      ],
    ]);
  });

  it("do nothing " +
  "if the current data version id the latest data version.", async () => {
    const testSysSnapshot = test.firestore.makeDocumentSnapshot(
        {...sysData, dataVersion: latestDataVersion},
        "document/service/sys",
    );

    await updateData(mockFirebase, testSysSnapshot);
    expect(mockUpdate.mock.calls).toEqual([]);
  });
});

describe("install()", () => {
  it("create sys, inv, copyright, policy," +
  " the primary account in testers group," +
  " the testers group with primary account," +
  " and returns document 'sys'.", async () => {
    const email = "primary@example.com";
    const password = "primary's password";
    const url = "https://example.com";
    mockedUsers.createAuthUser.mockImplementationOnce(
        () => Promise.resolve("id01")
    );
    mockGet.mockImplementationOnce(
        () => Promise.resolve(sysSnapshot as DocSnap)
    );

    const ret = await install(mockFirebase, email, password, url);

    expect(ret).toEqual(sysSnapshot);
    expect(mockedUsers.createAuthUser.mock.calls).toEqual([
      [
        mockFirebase,
        {
          name: "Primary user",
          admin: true,
          tester: true,
          group: "testers",
          email,
          password,
        },
      ],
    ]);
    expect(mockCollection.mock.calls).toEqual([
      ["service"],
      ["groups"],
    ]);
    expect(mockDoc.mock.calls).toEqual([
      ["sys"],
      ["inv"],
      ["copyright"],
      ["policy"],
      ["testers"],
      ["sys"],
    ]);
    expect(mockSet.mock.calls).toEqual([
      [
        {
          version: "1.0.0",
          url,
          createdAt: expect.any(Date),
          updatedAt: expect.any(Date),
        },
      ],
      [
        {
          seed: expect.any(String),
          expiration: 3 * 24 * 3600 * 1000,
          createdAt: expect.any(Date),
          updatedAt: expect.any(Date),
        },
      ],
      [
        {
          text: expect.any(String),
          createdAt: expect.any(Date),
          updatedAt: expect.any(Date),
        },
      ],
      [
        {
          text: expect.any(String),
          createdAt: expect.any(Date),
          updatedAt: expect.any(Date),
        },
      ],
      [
        {
          name: "テスト",
          desc: "テスト用のグループ",
          accounts: ["id01"],
          createdAt: expect.any(Date),
          updatedAt: expect.any(Date),
          deletedAt: null,
        },
      ],
    ]);
  });
});
