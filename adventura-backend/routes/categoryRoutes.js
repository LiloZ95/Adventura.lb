const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const { sequelize } = require("../db/db.js");
const { QueryTypes } = require("sequelize");

const router = express.Router();

// ✅ Configure multer storage for image uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, "uploads/"); // Images will be saved in 'uploads' directory
  },
  filename: function (req, file, cb) {
    cb(null, file.fieldname + "-" + Date.now() + path.extname(file.originalname));
  },
});

const upload = multer({ storage: storage });

/**
 * ✅ Get all categories
 * GET /categories
 */
router.get("/", async (req, res) => {
  try {
    const categories = await sequelize.query(
      `SELECT category_id, name FROM category`,
      { type: QueryTypes.SELECT }
    );

    res.status(200).json(categories);
  } catch (error) {
    console.error("❌ Error fetching categories:", error);
    res.status(500).json({ error: "Server error" });
  }
});

/**
 * ✅ Get a single category by ID
 * GET /categories/:categoryId
 */
router.get("/:categoryId", async (req, res) => {
  try {
    const { categoryId } = req.params;
    const category = await sequelize.query(
      `SELECT category_id, name, description, encode(image, 'base64') AS image FROM category WHERE category_id = :categoryId`,
      { replacements: { categoryId }, type: QueryTypes.SELECT }
    );

    if (!category.length) {
      return res.status(404).json({ error: "Category not found" });
    }

    res.status(200).json(category[0]);
  } catch (error) {
    console.error("❌ Error fetching category:", error);
    res.status(500).json({ error: "Server error" });
  }
});

/**
 * ✅ Upload category image
 * POST /categories/upload-image/:categoryId
 */
router.post("/upload-image/:categoryId", upload.single("image"), async (req, res) => {
  try {
    const { categoryId } = req.params;

    if (!req.file) {
      return res.status(400).json({ error: "No file uploaded" });
    }

    // Read the uploaded image file as binary
    const imagePath = req.file.path;
    const imageBuffer = fs.readFileSync(imagePath);

    // Update the database with the new image
    await sequelize.query(
      `UPDATE category SET image = :image WHERE category_id = :categoryId`,
      { replacements: { image: imageBuffer, categoryId }, type: QueryTypes.UPDATE }
    );

    res.status(200).json({ message: "Image uploaded successfully!" });
  } catch (error) {
    console.error("❌ Error uploading image:", error);
    res.status(500).json({ error: "Server error" });
  }
});

/**
 * ✅ Create a new category
 * POST /categories
 */
router.post("/", async (req, res) => {
  try {
    const { name, description } = req.body;

    if (!name) {
      return res.status(400).json({ error: "Category name is required" });
    }

    const newCategory = await sequelize.query(
      `INSERT INTO category (name, description) VALUES (:name, :description) RETURNING *`,
      { replacements: { name, description }, type: QueryTypes.INSERT }
    );

    res.status(201).json({ message: "Category created successfully!", category: newCategory });
  } catch (error) {
    console.error("❌ Error creating category:", error);
    res.status(500).json({ error: "Server error" });
  }
});

/**
 * ✅ Update category details
 * PUT /categories/:categoryId
 */
router.put("/:categoryId", async (req, res) => {
  try {
    const { categoryId } = req.params;
    const { name, description } = req.body;

    await sequelize.query(
      `UPDATE category SET name = :name, description = :description WHERE category_id = :categoryId`,
      { replacements: { name, description, categoryId }, type: QueryTypes.UPDATE }
    );

    res.status(200).json({ message: "Category updated successfully!" });
  } catch (error) {
    console.error("❌ Error updating category:", error);
    res.status(500).json({ error: "Server error" });
  }
});

/**
 * ✅ Delete a category
 * DELETE /categories/:categoryId
 */
router.delete("/:categoryId", async (req, res) => {
  try {
    const { categoryId } = req.params;

    await sequelize.query(
      `DELETE FROM category WHERE category_id = :categoryId`,
      { replacements: { categoryId }, type: QueryTypes.DELETE }
    );

    res.status(200).json({ message: "Category deleted successfully!" });
  } catch (error) {
    console.error("❌ Error deleting category:", error);
    res.status(500).json({ error: "Server error" });
  }
});

module.exports = router;
