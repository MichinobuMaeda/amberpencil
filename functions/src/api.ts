import {config} from "firebase-functions";
import {app} from "firebase-admin";
import {Request, Response} from "express";
import {AxiosStatic} from "axios";

import {
  getSys,
  updateVersion,
  updateData,
  install,
} from "./setup";

/* eslint-disable import/prefer-default-export */
export const setup = (
    firebase: app.App,
    axios: AxiosStatic,
    functionsConfig: config.Config,
) => async (
    req: Request,
    res: Response,
): Promise<Response> => {
  const sys = await getSys(firebase);
  if (sys) {
    const verUp = await updateVersion(sys, axios);
    if (verUp) {
      await updateData(firebase, sys);
    }
  } else {
    const sysNew = await install(
        firebase,
        functionsConfig.initial.email,
        functionsConfig.initial.password,
        functionsConfig.initial.url,
    );
    await updateData(firebase, sysNew);
  }
  return res.send("OK");
};
