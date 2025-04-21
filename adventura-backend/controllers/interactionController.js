const { Op } = require("sequelize");
const { UserActivityInteraction } = require("../models");

exports.logInteraction = async (req, res) => {
  const { user_id, activity_id, interaction_type, rating } = req.body;

  try {
    // Check if a recent interaction exists
    const limitTypes = ["view", "like", "share"]; // 🧠 purchase stays unlimited

if (limitTypes.includes(interaction_type)) {
  const recent = await UserActivityInteraction.findOne({
    where: {
      user_id,
      activity_id,
      interaction_type,
      createdAt: {
        [Op.gte]: new Date(Date.now() - 10 * 60 * 1000), // past 10 minutes
      },
    },
  });

  if (recent) {
    return res
      .status(200)
      .json({ message: `⏱️ Recent '${interaction_type}' already logged.` });
  }
}


    // Create new interaction
    await UserActivityInteraction.create({
      user_id,
      activity_id,
      interaction_type,
      rating,
      createdAt: new Date(),
      updatedAt: new Date(),
    });

    res.status(201).json({ message: "✅ Interaction logged" });
  } catch (err) {
    console.error("❌ Interaction insert error:", err.message);
    res.status(500).json({ error: err.message });
  }
};
