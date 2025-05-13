const express = require("express");
const multer = require("multer");
const fs = require("fs");
const path = require("path");
const { sequelize } = require("../db/db.js");
const { QueryTypes } = require("sequelize");

const {getAllCategories, getCategoryById, getCategoriesWithCounts, uploadCategoryImage,} = require("../controllers/categoryController");
const { get } = require("http");

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
router.get("/", getAllCategories);

router.get("/with-counts", getCategoriesWithCounts);

/**
 * ✅ Get a single category by ID
 * GET /categories/:categoryId
 */
router.get("/:categoryId", getCategoryById);


/**
 * ✅ Upload category image
 * POST /categories/upload-image/:categoryId
 */
router.post("/upload-image/:categoryId", upload.single("image"), uploadCategoryImage);

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
