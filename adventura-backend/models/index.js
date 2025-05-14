const { sequelize } = require("../db/db");
const { DataTypes } = require("sequelize");
const Activity = require("./Activity");
const ActivityImage = require("./ActivityImage");
const TripPlan = require("./TripPlan");
const Client = require("./client");
const Event = require("./Event");
const EventImage = require("./EventImage");
const User = require("./User");
const Provider = require("./Provider");
const UserPreferences = require("./UserPreferences");
const UserActivityInteraction = require("./UserActivityInteraction");
const Booking = require("./Booking");
const Feature = require("./Feature");
const Administrator = require("./Administrator");
const availability = require("./Availability");
const ActivityCategory = require("./ActivityCategory");
const NotificationModel = require("./Notification");
const UniversalNotificationModel = require("./UniversalNotification");
const Notification = require("./Notification");
const UniversalNotification = UniversalNotificationModel(sequelize, DataTypes);
const Payment = require("./Payment")(sequelize, DataTypes);
const ProviderRequest = require("./providerRequest"); // ✅ make sure path is correct
const Followers = require("./Followers");
const UserPfp = require("./UserPfp");
const Reel = require("./Reel");
const ReelLike = require("./ReelLike");
const ReelComment = require("./ReelComment");
const Addon = require("./Addon");

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

Activity.hasMany(TripPlan, {
	foreignKey: "activity_id",
	onDelete: "CASCADE",
});

Activity.belongsTo(Provider, { foreignKey: "provider_id", as: "provider" });
Provider.hasMany(Activity, { foreignKey: "provider_id", as: "activities" });

TripPlan.belongsTo(Activity, {
	foreignKey: "activity_id",
});

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

EventImage.belongsTo(Event, {
	foreignKey: "event_id",
});

UserActivityInteraction.belongsTo(Activity, {
	foreignKey: "activity_id",
	as: "activity",
});

UserActivityInteraction.belongsTo(User, {
	foreignKey: "user_id",
	as: "user",
});

// ✅ Activity ↔ Category
Activity.belongsTo(ActivityCategory, {
	foreignKey: "category_id",
	as: "category",
});

ActivityCategory.hasMany(Activity, {
	foreignKey: "category_id",
	as: "activities",
});

// ✅ User ↔ Provider & Client
User.hasOne(Provider, { foreignKey: "user_id" });
Provider.belongsTo(User, { foreignKey: "user_id" });

Client.belongsTo(User, {
	foreignKey: "user_id",
	as: "user",
});

User.hasMany(Notification, { foreignKey: "user_id" });
Notification.belongsTo(User, { foreignKey: "user_id" });

// ✅ Followers → User
Followers.belongsTo(User, {
	foreignKey: "user_id",
	targetKey: "user_id",
	as: "user",
});

// ✅ User → UserPfp
User.hasOne(UserPfp, {
	foreignKey: "user_id",
	sourceKey: "user_id",
	as: "user_pfp",
});
UserPfp.belongsTo(User, {
	foreignKey: "user_id",
	targetKey: "user_id",
	as: "user",
});

Provider.hasMany(Reel, { foreignKey: "provider_id" });
Reel.belongsTo(Provider, { foreignKey: "provider_id" });

User.hasMany(ReelLike, { foreignKey: "user_id" });
ReelLike.belongsTo(User, { foreignKey: "user_id" });

User.hasMany(ReelComment, { foreignKey: "user_id" });
ReelComment.belongsTo(User, { foreignKey: "user_id" });

Addon.belongsTo(Activity, { foreignKey: "activity_id" });
Activity.hasMany(Addon, { foreignKey: "activity_id", as: "addons" });

// ✅ Sync DB
sequelize
	.sync({ alter: { drop: false } })
	.then(() => console.log("✅ Database & tables synced!"))
	.catch((err) => console.error("❌ Error syncing database:", err));

// ✅ Export All Models
module.exports = {
	sequelize,
	Activity,
	Booking,
	Client,
	ActivityImage,
	UserPreferences,
	Event,
	EventImage,
	UserActivityInteraction,
	Administrator,
	TripPlan,
	Feature,
	User,
	Payment,
	Provider,
	ProviderRequest,
	availability,
	ActivityCategory,
	Notification,
	UniversalNotification,
	Followers,
	UserPfp,
	Addon,
};
