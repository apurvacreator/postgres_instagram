import express from "express";
import usersRouter from "./routes/users.js";

export default () => {
  const app = express();

  app.use(express.json());
  app.use(usersRouter);

  return app;
};
