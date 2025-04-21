const { sequelize, UserActivityInteraction, Activity } = require('../models');
const { Op } = require('sequelize');

async function updateTrendingActivities() {
  const sinceDate = new Date(Date.now() - 3 * 24 * 60 * 60 * 1000); // Last 3 days

  console.log("🔄 Checking interactions since:", sinceDate.toISOString());

  const interactions = await UserActivityInteraction.findAll({
    where: {
      createdAt: { [Op.gte]: sinceDate },
    },
  });

  const activityMap = {};

  interactions.forEach(({ activity_id, interaction_type }) => {
    if (!activityMap[activity_id]) {
      activityMap[activity_id] = { view: 0, like: 0, share: 0 };
    }
    if (interaction_type in activityMap[activity_id]) {
      activityMap[activity_id][interaction_type]++;
    }
  });

  const trendingIds = [];

  for (const [activityId, counts] of Object.entries(activityMap)) {
    if (
      counts.view >= 15 ||
      counts.like >= 5 ||
      counts.share >= 3
    ) {
      trendingIds.push(Number(activityId));
    }
  }

  console.log("📊 Trending ID Candidates:", trendingIds);

  // DEBUG: Check how many actually exist in DB
  const existingActivities = await Activity.findAll({
    where: { activity_id: trendingIds },
  });

  console.log("🧾 Found Activities:", existingActivities.map(a => ({
    id: a.activity_id,
    currentTrending: a.is_trending,
  })));

  // Reset all
  await Activity.update({ is_trending: false }, { where: {} });
  console.log("🔁 Reset is_trending for all activities");

  // Update trending
  if (trendingIds.length > 0) {
    const updateResult = await Activity.update(
      { is_trending: true },
      { where: { activity_id: trendingIds } }
    );

    console.log("✅ Set trending result:", updateResult);
  } else {
    console.log("⚠️ No activities qualified as trending");
  }

//   console.log("🔍 Final Activity Map:", JSON.stringify(activityMap, null, 2));
//   console.log(`🔥 Done. Updated trending activities: ${trendingIds.join(', ')}`);
}

module.exports = updateTrendingActivities;
