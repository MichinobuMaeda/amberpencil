const {
  createFirestoreDocSnapMock,
  createMockFirebase,
} = require("./testutils");
const {
  requireValidAccount,
  requireAdminAccount,
} = require("./guard");

const doc1 = createFirestoreDocSnapMock(jest, "user01id");
const {
  mockDocRef,
  firebase,
} = createMockFirebase(jest);

const mockCbReturnValue = "Return value of cb";
const mockCb = jest.fn(async function(a, b) {
  return mockCbReturnValue;
});

afterEach(async function() {
  jest.clearAllMocks();
});

describe("requireValidAccount", function() {
  it("throw error," +
    " if uid is undefined", async function() {
    expect(
        () => requireValidAccount(firebase, undefined, mockCb),
    ).rejects.toThrow("uid: undefined");
  });

  it("throw error," +
    " if uid has no corresponding doc.", async function() {
    mockDocRef.get.mockResolvedValue({exists: false});

    expect(
        () => requireValidAccount(firebase, doc1.id, mockCb),
    ).rejects.toThrow(`uid: ${doc1.id}, exists: false`);
  });

  it("throw error," +
    " if the account is invalid.", async function() {
    doc1.data.mockReturnValue({valid: false});
    mockDocRef.get.mockResolvedValue(doc1);

    await expect(
        () => requireValidAccount(firebase, doc1.id, mockCb),
    ).rejects.toThrow(`uid: ${doc1.id}, valid: false`);
  });

  it("throw error," +
    " if the account is deleted.", async function() {
    doc1.data.mockReturnValue({valid: true, deletedAt: new Date()});
    mockDocRef.get.mockResolvedValue(doc1);

    await expect(
        () => requireValidAccount(firebase, doc1.id, mockCb),
    ).rejects.toThrow(expect.objectContaining({
      message: expect.stringContaining(`uid: ${doc1.id}, deletedAt:`),
    }));
  });

  it("call cb() for valid user.", async function() {
    doc1.data.mockReturnValue({valid: true, admin: false});
    mockDocRef.get.mockResolvedValue(doc1);

    const ret = await requireValidAccount(firebase, doc1.id, mockCb);
    expect(mockCb.mock.calls).toEqual([[firebase, doc1.id]]);
    expect(ret).toEqual(mockCbReturnValue);
  });

  it("call cb() for admin user.", async function() {
    doc1.data.mockReturnValue({valid: true, admin: true});
    mockDocRef.get.mockResolvedValue(doc1);

    const ret = await requireValidAccount(firebase, doc1.id, mockCb);
    expect(mockCb.mock.calls).toEqual([[firebase, doc1.id]]);
    expect(ret).toEqual(mockCbReturnValue);
  });
});

describe("requireAdminAccount", function() {
  it("throw error," +
    " if uid is undefined", async function() {
    expect(
        () => requireAdminAccount(firebase, undefined, mockCb),
    ).rejects.toThrow("uid: undefined");
  });

  it("throw error," +
    " if uid has no corresponding doc.", async function() {
    mockDocRef.get.mockResolvedValue({exists: false});

    expect(
        () => requireAdminAccount(firebase, doc1.id, mockCb),
    ).rejects.toThrow(`uid: ${doc1.id}, exists: false`);
  });

  it("throw error," +
    " if the account is invalid.", async function() {
    doc1.data.mockReturnValue({valid: false});
    mockDocRef.get.mockResolvedValue(doc1);

    await expect(
        () => requireAdminAccount(firebase, doc1.id, mockCb),
    ).rejects.toThrow(`uid: ${doc1.id}, valid: false`);
  });

  it("throw error," +
    " if the account is deleted.", async function() {
    doc1.data.mockReturnValue({valid: true, deletedAt: new Date()});
    mockDocRef.get.mockResolvedValue(doc1);

    await expect(
        () => requireAdminAccount(firebase, doc1.id, mockCb),
    ).rejects.toThrow(expect.objectContaining({
      message: expect.stringContaining(`uid: ${doc1.id}, deletedAt:`),
    }));
  });

  it("call cb() for valid user.", async function() {
    doc1.data.mockReturnValue({valid: true, admin: false});
    mockDocRef.get.mockResolvedValue(doc1);

    await expect(
        () => requireAdminAccount(firebase, "user01", mockCb),
    ).rejects.toThrow("uid: user01, admin: false");
  });

  it("call cb() for admin user.", async function() {
    doc1.data.mockReturnValue({valid: true, admin: true});
    mockDocRef.get.mockResolvedValue(doc1);

    const ret = await requireAdminAccount(firebase, doc1.id, mockCb);
    expect(mockCb.mock.calls).toEqual([[firebase, doc1.id]]);
    expect(ret).toEqual(mockCbReturnValue);
  });
});