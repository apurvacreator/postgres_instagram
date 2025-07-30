import { runner } from "node-pg-migrate";
import { randomBytes } from "crypto";
import format from "pg-format";
import dotenv from "dotenv";
import pool from "../pool";

dotenv.config();

const DEFAULT_OPS = {
  host: "localhost",
  port: 5432,
  database: process.env.sndb_test,
  user: process.env.username,
  password: "",
};

class Context {
  constructor(roleName) {
    this.roleName = roleName;
  }

  static async build() {
    // Randomly generating a role name to connect to PG as
    const roleName = "a" + randomBytes(4).toString("hex");

    // Connect to PG as usual
    await pool.connect(DEFAULT_OPS);

    // Create a new role
    await pool.query(
      format(
        "CREATE ROLE %I WITH LOGIN PASSWORD %L;",
        roleName,
        roleName
      )
    );

    // Create a schema with the same name
    await pool.query(
      format(
        "CREATE SCHEMA %I AUTHORIZATION %I;",
        roleName,
        roleName
      )
    );

    // Disconnect entirely from PG
    await pool.close();

    // Run migrations in the new schema
    await runner({
      schema: roleName,
      direction: "up",
      log: () => {},
      noLock: true,
      dir: "migrations",
      databaseUrl: {
        host: "localhost",
        port: 5432,
        database: process.env.sndb_test,
        user: roleName,
        password: roleName,
      },
    });

    // Connect to PG as the newly created role
    await pool.connect({
      host: "localhost",
      port: 5432,
      database: process.env.sndb_test,
      user: roleName,
      password: roleName,
    });

    return new Context(roleName);
  }

  async close() {
    await pool.close();
    await pool.connect(DEFAULT_OPS);
    await pool.query(
      format("DROP SCHEMA %I CASCADE;", this.roleName)
    );
    await pool.query(
      format("DROP ROLE %I;", this.roleName)
    );
    await pool.close();
  }

  async reset() {
    return pool.query(`
        DELETE FROM users;    
    `);
  }
}

export default Context;
