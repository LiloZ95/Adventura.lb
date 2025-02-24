// controllers/userController.js
const bcrypt = require('bcryptjs'); // Use bcryptjs instead of bcrypt
const jwt = require("jsonwebtoken");
const sequelize = require("../db/db.js"); // Import Sequelize instance
const User = require("../models/User");
const { QueryTypes } = require("sequelize");

const getAllUsers = async (req, res) => {
  try {
    const [users] = await sequelize.query('SELECT * FROM "USER"'); // Raw query
    console.log("Fetched users:", users);
    res.status(200).json(users);
  } catch (err) {
    console.error("Database error:", err);
    res.status(500).json({ error: "Server error" });
  };
}

const getUserById = async (req, res) => {
  const { id } = req.params;
  try {
    // Fetch users directly as an array (not an object with `rows`)
    const users = await sequelize.query('SELECT * FROM "USER" WHERE user_id = :id', {
      replacements: { id },
      type: sequelize.QueryTypes.SELECT,
    });

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.status(200).json(users[0]); // Return the first user
  } catch (err) {
    console.error("Database error:", err);
    res.status(500).json({ error: 'Server error' });
  }
};

const createUser = async (req, res) => {
  const { first_name, last_name, password, email, phone_number, location, user_type } = req.body;

  // Validate input
  if (!first_name || !last_name || !password || !email || !phone_number) {
    return res.status(400).json({ error: "All fields are required" });
  }

  // Default user_type to "client" if not provided
  const finalUserType = user_type || "client";

  // Validate email format
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return res.status(400).json({ error: "Invalid email format" });
  }

  try {
    // Check if user already exists (email or username)
    const existingUser = await User.findOne({ where: { email } });
    if (existingUser) {
      return res.status(400).json({ error: "User with this email already exists" });
    }

    // **Hash the password before saving it**
    const salt = await bcrypt.genSalt(10); // Generate a salt
    const hashedPassword = await bcrypt.hash(password, salt); // Hash password

    // Create new user in "User" table
    const newUser = await User.create({
      first_name,
      last_name,
      password_hash: hashedPassword,
      email,
      phone_number,
      location,
      user_type: finalUserType,
    });

    console.log(`✅ New user "${newUser.first_name} ${newUser.last_name}" created with type: ${newUser.user_type}`);

    // Auto-distribute the user to the correct table
    await distributeUser(newUser);

    res.status(201).json({ message: "User registered successfully!", user: newUser });
  } catch (err) {
    console.error("Error creating user:", err);
    res.status(500).json({ error: "Server error", details: err.message });
  }
};

// Function to distribute user into correct table
const distributeUser = async (user) => {
  try {
    switch (user.user_type) {
      case "provider":
        await sequelize.query(
          `INSERT INTO provider (user_id, business_name) 
           SELECT :userId, 'Default Business' 
           WHERE NOT EXISTS (SELECT 1 FROM PROVIDER WHERE user_id = :userId)`,
          {
            replacements: { userId: user.user_id },
            type: QueryTypes.INSERT,
          }
        );
        console.log(`✅ User "${user.first_name} ${user.last_name}" assigned to PROVIDER`);
        break;

      case "admin":
        await sequelize.query(
          `INSERT INTO administrator (user_id, permissions, admin_role) 
           SELECT :userId, 'All', 'Super Admin' 
           WHERE NOT EXISTS (SELECT 1 FROM ADMINISTRATOR WHERE user_id = :userId)`,
          {
            replacements: { userId: user.user_id },
            type: QueryTypes.INSERT,
          }
        );
        console.log(`✅ User "${user.first_name} ${user.last_name}" assigned to ADMINISTRATOR`);
        break;

      default: // Default all other users to CLIENT
        await sequelize.query(
          `INSERT INTO client (user_id, preferences, loyalty_points) 
           SELECT :userId, 'No preferences', 0 
           WHERE NOT EXISTS (SELECT 1 FROM CLIENT WHERE user_id = :userId)`,
          {
            replacements: { userId: user.user_id },
            type: QueryTypes.INSERT,
          }
        );
        console.log(`✅ User "${user.first_name} ${user.last_name}" assigned to CLIENT (Default)`);
        break;
    }
  } catch (error) {
    console.error(`❌ Error distributing user "${user.first_name} ${user.last_name}":`, error);
  }
};

const updateUser = async (req, res) => {
  const { id } = req.params;
  const { username, password, email, phone_number, location, user_type } = req.body;

  try {
    let password_hash = null;
    
    if (password) {
      password_hash = await bcrypt.hash(password, 10); // Hash new password
    }

    const { rows } = await db.query(
      'UPDATE "USER" SET username = $1, password_hash = COALESCE($2, password_hash), email = $3, phone_number = $4, location = $5, user_type = $6 WHERE user_id = $7 RETURNING *',
      [username, password_hash, email, phone_number, location, user_type, id]
    );

    if (rows.length === 0) {
      return res.status(404).send('User not found');
    }
    
    res.status(200).json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).send('Server error');
  }
};

// Delete user from every table.
const deleteUser = async (req, res) => {
  const { id } = req.params;

  try {
    if (!id) {
      console.log("❌ Error: No userId provided");
      return res.status(400).json({ success: false, error: "User ID is required." });
    }

    console.log(`🗑 Attempting to delete user with ID: ${id}`);

    // Check if user exists before deleting
    const user = await User.findOne({ where: { user_id: id } });

    if (!user) {
      console.log("❌ Error: No userId provided");
      return res.status(404).json({ error: "User not found" });
    }

    // ✅ Start transaction to ensure consistency
    await sequelize.transaction(async (t) => {
      // ✅ Delete user from all related tables
      await sequelize.query(`DELETE FROM provider WHERE user_id = :id`, {
        replacements: { id },
        type: QueryTypes.DELETE,
        transaction: t,
      });

      await sequelize.query(`DELETE FROM administrator WHERE user_id = :id`, {
        replacements: { id },
        type: QueryTypes.DELETE,
        transaction: t,
      });

      await sequelize.query(`DELETE FROM client WHERE user_id = :id`, {
        replacements: { id },
        type: QueryTypes.DELETE,
        transaction: t,
      });

      // ✅ Finally, delete the user from the USER table
      await sequelize.query(`DELETE FROM "USER" WHERE user_id = :id`, {
        replacements: { id },
        type: QueryTypes.DELETE,
        transaction: t,
      });

      console.log(`✅ User ${id} deleted from all tables successfully.`);
    });

    res.status(200).json({ success: true, message: "User deleted successfully from all tables" });

  } catch (err) {
    console.error("❌ Error deleting user:", err);
    res.status(500).json({ error: "Failed to delete user" });
  }
};


const loginUser = async (req, res) => {
  const { email, password } = req.body;

  try {
    // Use Sequelize's findOne instead of raw SQL
    const user = await User.findOne({ where: { email } });

    if (!user) {
      return res.status(404).json({ message: "User not found" });
    }

    // Compare entered password with hashed password
    const isMatch = await bcrypt.compare(password, user.password_hash);
    if (!isMatch) {
      return res.status(401).json({ error: "Invalid password" });
    }

    // Compare passwords as plain text
    // if (password !== user.password_hash) {
    //   return res.status(401).json({ message: "Invalid password" });
    // }
    // Create JWT token
    const accessToken = jwt.sign(
      { userId: user.user_id, email: user.email, userType: user.user_type },
      process.env.JWT_SECRET,
      { expiresIn: "1h" } // Token expires in 1 hour
    );

    const refreshToken = jwt.sign(
      { userId: user.user_id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: "30d" } // Refresh token lasts 30 days
    );

    res.status(200).json({ message: "Login successful!", accessToken, refreshToken });

  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({ error: "Server error" });
  }
};

const refreshAccessToken = (req, res) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return res.status(401).json({ error: "Refresh token required" });
  }

  try {
    const decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET); // Verify the refresh token
    const newAccessToken = jwt.sign(
      { userId: decoded.userId, email: decoded.email, userType: decoded.userType },
      process.env.JWT_SECRET,
      { expiresIn: "1h" } // Token expires in 1 hour
    );

    res.json({ accessToken: newAccessToken });
  } catch (err) {
    res.status(403).json({ error: "Invalid refresh token" });
  }
};

module.exports = {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  loginUser,
  refreshAccessToken,
};