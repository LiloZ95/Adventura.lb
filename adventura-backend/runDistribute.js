const { distributeUser } = require("./distributeUsers");
const User = require("./models/User"); // Ensure this path is correct

(async () => {
  try {
    const user = await User.findByPk(10); // Replace 1 with the actual user ID you want to test
    if (!user) {
      console.log("User not found");
      return;
    }

    await distributeUser(user);
  } catch (err) {
    console.error("❌ Error running distributeUser:", err);
  }
})();
