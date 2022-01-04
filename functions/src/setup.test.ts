import functionTest from "firebase-functions-test";
import axios from "axios";
import {
  DocRef,
  DocSnap,
  confNotExist,
  confData,
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
  getConf,
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
const confSnapshot: Partial<DocSnap> = {
  id: "conf",
  exists: true,
  get: (key) => {
    switch (key) {
      case "version": return confData.version;
      case "url": return confData.url;
      case "createdAt": return confData.createdAt;
      case "updatedAt": return confData.updatedAt;
      default: return undefined;
    }
  },
  ref: mockSysRef as DocRef,
};

beforeEach(() => {
  jest.clearAllMocks();
});

describe("getSys()", () => {
  it("returns null if document \"conf\" is not exists.", async () => {
    mockGet
        .mockImplementationOnce(() => new Promise((resolve) => {
          resolve(confNotExist);
        }));
    const conf = await getConf(mockFirebase);
    expect(conf).toBeNull();
  });

  it("returns document \"conf\" if document \"conf\" is exists.", async () => {
    mockGet
        .mockImplementationOnce(() => new Promise((resolve) => {
          resolve(confSnapshot as DocSnap);
        }));
    const conf = await getConf(mockFirebase);
    expect(conf).toEqual(confSnapshot);
  });
});

describe("updateVersion()", () => {
  it("returns false and not modifies conf has same version.", async () => {
    mockedAxios.get.mockResolvedValue({
      data: {version: confData.version},
    });

    expect(
        await updateVersion(confSnapshot as DocSnap, mockedAxios)
    ).toBeFalsy();
    expect(mockUpdate.mock.calls).toEqual([]);
  });

  it("returns true and update conf has old version.", async () => {
    mockedAxios.get.mockResolvedValue({
      data: {version: "1.0.1"},
    });
    expect(
        await updateVersion(confSnapshot as DocSnap, mockedAxios)
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

    await updateData(mockFirebase, confSnapshot as DocSnap);
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
        {...confData, dataVersion: latestDataVersion},
        "document/service/conf",
    );

    await updateData(mockFirebase, testSysSnapshot);
    expect(mockUpdate.mock.calls).toEqual([]);
  });
});

describe("install()", () => {
  it("create conf," +
  " the primary account in testers group," +
  " the testers group with primary account," +
  " and returns document 'conf'.", async () => {
    const email = "primary@example.com";
    const password = "primary's password";
    const url = "https://example.com";
    mockedUsers.createAuthUser.mockImplementationOnce(
        () => Promise.resolve("id01")
    );
    mockGet.mockImplementationOnce(
        () => Promise.resolve(confSnapshot as DocSnap)
    );

    const ret = await install(mockFirebase, email, password, url);

    expect(ret).toEqual(confSnapshot);
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
      ["conf"],
      ["testers"],
      ["conf"],
    ]);
    expect(mockSet.mock.calls).toEqual([
      [
        {
          version: "1.0.0",
          url,
          seed: expect.any(String),
          invitationExpirationTime: 3 * 24 * 3600 * 1000,
          policy: expect.any(String),
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
