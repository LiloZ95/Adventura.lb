const { sequelize } = require("../db/db");
const Activity = require("./Activity");
const ActivityImage = require("./ActivityImage");
const TripPlan = require("./TripPlan");
const Client = require("./client");
const Event = require("./Event"); // ✅ Add Event model
const EventImage = require("./EventImage"); // ✅ Add EventImage model
const UserPreferences = require("./UserPreferences");
const UserActivityInteraction = require("./UserActivityInteraction");
const Booking = require("./Booking");
const Feature = require("./Feature");

// ✅ Define Relationships
Activity.hasMany(ActivityImage, {
	foreignKey: "activity_id",
	as: "activity_images",
	onDelete: "CASCADE",
});
Activity.hasMany(Booking, {
	foreignKey: "activity_id",
	as: "activity_bookings",
});
Activity.hasMany(Feature, {
	foreignKey: "activity_id",
	as: "features",
});

Activity.hasMany(TripPlan, { foreignKey: "activity_id", onDelete: "CASCADE" });
TripPlan.belongsTo(Activity, { foreignKey: "activity_id" });

ActivityImage.belongsTo(Activity, {
	foreignKey: "activity_id",
	as: "activity_images",
});

Booking.belongsTo(Activity, {
	foreignKey: "activity_id",
	as: "activity",
});
Booking.belongsTo(Client, {
	foreignKey: "client_id",
	as: "client",
});

Client.hasMany(Booking, {
	foreignKey: "client_id",
	as: "client_bookings",
});

Event.hasMany(EventImage, {
	foreignKey: "event_id",
	as: "event_images",
	onDelete: "CASCADE",
});
EventImage.belongsTo(Event, { foreignKey: "event_id" });

UserActivityInteraction.belongsTo(Activity, {
	foreignKey: "activity_id",
	as: "activity",
});
UserActivityInteraction.belongsTo(UserPreferences, {
	foreignKey: "user_id",
	as: "user",
});

sequelize
	.sync({ alter: { drop: false } })
	.then(() => console.log("✅ Database & tables synced!"))
	.catch((err) => console.error("❌ Error syncing database:", err));

module.exports = {
	Activity,
	Booking,
	Client,
	ActivityImage,
	UserPreferences,
	Event,
	EventImage,
	sequelize,
	UserActivityInteraction,
	TripPlan,
	Feature,
};
