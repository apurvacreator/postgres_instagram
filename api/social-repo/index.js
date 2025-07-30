import app from "./src/app.js";
import pool from "./src/pool.js";
import dotenv from "dotenv";

dotenv.config();

pool
  .connect({
    host: "localhost",
    port: 5432,
    database: process.env.sndb,
    user: process.env.username,
    password: "",
  })
  .then(() => {
    app().listen(3005, () => {
      console.log("Listening on PORT 3005");
    });
  })
  .catch((err) => console.error(err));
