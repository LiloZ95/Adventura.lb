const { sequelize } = require("../db/db");

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
const availability = require("./Availability");
const ActivityCategory = require('./ActivityCategory');

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
  onDelete: "CASCADE"
});

TripPlan.belongsTo(Activity, {
  foreignKey: "activity_id"
});

ActivityImage.belongsTo(Activity, {
  foreignKey: "activity_id",
  as: "activity_images",
});

Booking.belongsTo(Activity, {
  foreignKey: "activity_id",
  as: "activity"
});

Booking.belongsTo(Client, {
  foreignKey: "client_id",
  as: "client"
});

Client.hasMany(Booking, {
  foreignKey: "client_id",
  as: "client_bookings"
});

Event.hasMany(EventImage, {
  foreignKey: "event_id",
  as: "event_images",
  onDelete: "CASCADE"
});

EventImage.belongsTo(Event, {
  foreignKey: "event_id"
});

UserActivityInteraction.belongsTo(Activity, {
  foreignKey: "activity_id",
  as: "activity"
});

UserActivityInteraction.belongsTo(User, {
  foreignKey: "user_id",
  as: "user"
});

// ✅ Activity ↔ Category
Activity.belongsTo(ActivityCategory, {
  foreignKey: 'category_id',
  as: 'category'
});

ActivityCategory.hasMany(Activity, {
  foreignKey: 'category_id',
  as: 'activities'
});

// ✅ User ↔ Provider & Client
User.hasOne(Provider, { foreignKey: "user_id" });
Provider.belongsTo(User, { foreignKey: "user_id" });

Client.belongsTo(User, {
  foreignKey: "user_id",
  as: "user"
});

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
  TripPlan,
  Feature,
  User,
  Provider,
  availability,
  ActivityCategory
};
