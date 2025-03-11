const { sequelize } = require("../db/db"); 
const Activity = require("./Activity");
const ActivityImage = require("./ActivityImage");
const Event = require("./Event");  // ✅ Add Event model
const EventImage = require("./EventImage"); // ✅ Add EventImage model
const UserPreferences = require("./UserPreferences");
const UserActivityInteraction = require("./UserActivityInteraction");

// ✅ Define Relationships
Activity.hasMany(ActivityImage, { foreignKey: "activity_id", as: "activity_images", onDelete: "CASCADE" });
ActivityImage.belongsTo(Activity, { foreignKey: "activity_id", as: "activity_images" });

Event.hasMany(EventImage, { foreignKey: "event_id", as: "event_images", onDelete: "CASCADE" });
EventImage.belongsTo(Event, { foreignKey: "event_id", as: "event_images" });

UserActivityInteraction.belongsTo(Activity, { foreignKey: "activity_id", as: "activity" });
UserActivityInteraction.belongsTo(UserPreferences, { foreignKey: "user_id", as: "user" });

sequelize.sync({ alter: true })
  .then(() => console.log("✅ Database & tables synced!"))
  .catch((err) => console.error("❌ Error syncing database:", err));

module.exports = { Activity, ActivityImage, UserPreferences, Event, EventImage, sequelize, UserActivityInteraction };
