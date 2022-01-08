import {config} from "firebase-functions";
import {app} from "firebase-admin";
import {Request, Response} from "express";

import {
  getConf,
  updateVersion,
  updateData,
  install,
} from "./setup";

/* eslint-disable import/prefer-default-export */
export const setup = (
    firebase: app.App,
    functionsConfig: config.Config,
) => async (
    req: Request,
    res: Response,
): Promise<Response> => {
  const conf = await getConf(firebase);
  if (conf) {
    const verUp = await updateVersion(conf, functionsConfig);
    if (verUp) {
      await updateData(firebase, conf);
    }
  } else {
    const confNew = await install(
        firebase,
        functionsConfig.initial.email,
        functionsConfig.initial.password,
        functionsConfig.initial.url,
    );
    await updateData(firebase, confNew);
  }
  return res.send("OK");
};
