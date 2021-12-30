import {Request, Response} from "express";
import axios from "axios";
import {
  sysSnapshot,
  mockFirebase,
} from "./testSetup";
import * as setupModule from "./setup";
import {
  setup,
} from "./api";

jest.mock("axios");
const mockedAxios = axios as jest.Mocked<typeof axios>;

jest.mock("./setup");
const mockedSetup = setupModule as jest.Mocked<typeof setupModule>;

beforeEach(() => {
  jest.clearAllMocks();
});

describe("setup()", () => {
  const config = {
    initial: {
      email: "info@example.com",
      password: "testpass",
      url: "https://example.com",
    },
  };
  const req: Partial<Request> = {};
  const mockSend = jest.fn();
  const res: Partial<Response> = {
    send: mockSend,
  };

  it("calls only updateVersion() " +
  "if conf.version is latest value.", async () => {
    mockedSetup.getSys.mockImplementationOnce(
        () => Promise.resolve(sysSnapshot)
    );
    mockedSetup.updateVersion.mockImplementationOnce(
        () => Promise.resolve(false)
    );

    const fn = setup(mockFirebase, mockedAxios, config);
    await fn(req as Request, res as Response);

    expect(mockedSetup.getSys.mock.calls).toEqual([[mockFirebase]]);
    expect(mockedSetup.updateVersion.mock.calls).toEqual(
        [[sysSnapshot, mockedAxios]]
    );
    expect(mockedSetup.updateData.mock.calls).toEqual([]);
    expect(mockedSetup.install.mock.calls).toEqual([]);
    expect(mockSend.mock.calls).toEqual([["OK"]]);
  });

  it("calls updateVersion() and updateData() " +
  "if conf.version is not value.", async () => {
    mockedSetup.getSys.mockImplementationOnce(
        () => Promise.resolve(sysSnapshot)
    );
    mockedSetup.updateVersion.mockImplementationOnce(
        () => Promise.resolve(true)
    );

    const fn = setup(mockFirebase, mockedAxios, config);
    await fn(req as Request, res as Response);

    expect(mockedSetup.getSys.mock.calls).toEqual([[mockFirebase]]);
    expect(mockedSetup.updateVersion.mock.calls).toEqual(
        [[sysSnapshot, mockedAxios]]
    );
    expect(mockedSetup.updateData.mock.calls).toEqual(
        [[mockFirebase, sysSnapshot]]
    );
    expect(mockedSetup.install.mock.calls).toEqual([]);
    expect(mockSend.mock.calls).toEqual([["OK"]]);
  });

  it("calls install() and updateData() " +
  "if conf is not exists.", async () => {
    mockedSetup.getSys.mockImplementationOnce(
        () => Promise.resolve(null)
    );
    mockedSetup.install.mockImplementationOnce(
        () => Promise.resolve(sysSnapshot)
    );

    const fn = setup(mockFirebase, mockedAxios, config);
    await fn(req as Request, res as Response);

    expect(mockedSetup.getSys.mock.calls).toEqual([[mockFirebase]]);
    expect(mockedSetup.updateVersion.mock.calls).toEqual([]);
    expect(mockedSetup.updateData.mock.calls).toEqual(
        [[mockFirebase, sysSnapshot]]
    );
    expect(mockedSetup.install.mock.calls).toEqual([[
      mockFirebase,
      config.initial.email,
      config.initial.password,
      config.initial.url,
    ]]);
    expect(mockSend.mock.calls).toEqual([["OK"]]);
  });
});
