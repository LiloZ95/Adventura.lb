const { sequelize } = require("../db/db");
const { QueryTypes } = require("sequelize");

const getAllCategories = async (req, res) => {
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
};

const getCategoryById = async (req, res) => {
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
};

const getCategoriesWithCounts = async (req, res) => {
	try {
		const result = await sequelize.query(
			`
                SELECT c.category_id, c.name, COUNT(a.activity_id) AS activity_count
                FROM category c
                JOIN activities a ON a.category_id = c.category_id
                WHERE a.availability_status = true
                GROUP BY c.category_id, c.name
                HAVING COUNT(a.activity_id) > 0
                ORDER BY COUNT(a.activity_id) DESC;
            `,
			{ type: QueryTypes.SELECT }
		);

		res.status(200).json(result);
	} catch (error) {
		console.error("❌ Error getting categories with counts:", error);
		res.status(500).json({ error: "Internal server error" });
	}
};

const uploadCategoryImage = async (req, res) => {
	try {
		const { categoryId } = req.params;

		if (!req.file) {
			return res.status(400).json({ error: "No file uploaded" });
		}

		const imagePath = req.file.path;
		const imageBuffer = fs.readFileSync(imagePath);

		await sequelize.query(
			`UPDATE category SET image = :image WHERE category_id = :categoryId`,
			{
				replacements: { image: imageBuffer, categoryId },
				type: QueryTypes.UPDATE,
			}
		);

		res.status(200).json({ message: "Image uploaded successfully!" });
	} catch (error) {
		console.error("❌ Error uploading image:", error);
		res.status(500).json({ error: "Server error" });
	}
};

module.exports = {
	getAllCategories,
	getCategoryById,
	getCategoriesWithCounts,
	uploadCategoryImage,
};
