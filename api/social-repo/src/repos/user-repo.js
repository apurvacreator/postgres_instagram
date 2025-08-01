import pool from "../pool.js";
import toCamelCase from "./utils/to-camel-case.js";

class UserRepo {
  static async find() {
    const { rows } = await pool.query(
      "SELECT * FROM users;"
    );

    return toCamelCase(rows);
  }

  static async findById(id) {
    const { rows } = await pool.query(
      "SELECT * FROM users WHERE users.id = $1;",
      [id]
    );

    return toCamelCase(rows)[0];
  }

  static async insert(username, bio) {
    const { rows } = await pool.query(
      "INSERT INTO users (username, bio) VALUES ($1, $2) RETURNING *",
      [username, bio]
    );
    return toCamelCase(rows)[0];
  }

  static async update(id, username, bio) {
    const { rows } = await pool.query(
      "UPDATE users SET username = $1, bio = $2 WHERE id = $3 RETURNING *",
      [username, bio, id]
    );

    return toCamelCase(rows)[0];
  }

  static async delete(id) {
    const { rows } = await pool.query(
      "DELETE FROM users WHERE id = $1 RETURNING *",
      [id]
    );

    return toCamelCase(rows)[0];
  }

  static async count() {
    const { rows } = await pool.query(
      "SELECT COUNT(*) FROM users;"
    );

    return +rows[0].count;
  }
}

export default UserRepo;
