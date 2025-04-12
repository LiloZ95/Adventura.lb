const { OAuth2Client } = require("google-auth-library");
const axios = require("axios");
const jwt = require("jsonwebtoken");
const User = require("../models/User");

const googleClient = new OAuth2Client();
const refreshTokens = [];

exports.loginWithGoogle = async (req, res) => {
  const { idToken } = req.body;
  if (!idToken) return res.status(400).json({ error: "Missing idToken" });

  try {
    const ticket = await googleClient.verifyIdToken({ idToken });
    const payload = ticket.getPayload();

    const email = payload.email;
    const firstName = payload.given_name;
    const lastName = payload.family_name;
    const profilePicture = payload.picture;
    const providerId = payload.sub;

    let user = await User.findOne({ where: { email } });

    if (!user) {
      user = await User.create({
        first_name: firstName,
        last_name: lastName,
        email,
        user_type: "client", // or 'provider' if you want to default
        auth_provider_type: "google",
        auth_provider_id: providerId,
        external_profile_picture: profilePicture,
        password_hash: null,
      });
    }

    const accessToken = jwt.sign(
      {
        userId: user.user_id,
        email: user.email,
        userType: user.user_type,
      },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    const refreshToken = jwt.sign(
      { userId: user.user_id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: "7d" }
    );

    // Optional: Store in memory if you want to track it (like your other logic)
    refreshTokens.add(refreshToken);

    return res.status(200).json({
      success: true,
      accessToken,
      refreshToken,
      user,
    });
  } catch (err) {
    console.error("❌ Google login error:", err);
    return res.status(500).json({ error: "Google login failed" });
  }
};

exports.loginWithFacebook = async (req, res) => {
  const { accessToken } = req.body;
  if (!accessToken)
    return res.status(400).json({ error: "Missing accessToken" });

  try {
    const response = await axios.get(
      `https://graph.facebook.com/me?fields=id,name,email,picture.type(large)&access_token=${accessToken}`
    );

    const fbData = response.data;
    const [firstName, ...rest] = fbData.name.split(" ");
    const lastName = rest.join(" ") || "";
    const profilePicture = fbData.picture?.data?.url || null;

    let user = await User.findOne({ where: { email: fbData.email } });

    if (!user) {
      user = await User.create({
        first_name: firstName,
        last_name: lastName,
        email: fbData.email,
        user_type: "client",
        auth_provider_type: "facebook",
        auth_provider_id: fbData.id,
        external_profile_picture: profilePicture,
        password_hash: null,
      });
    }

    const accessToken = jwt.sign(
      {
        userId: user.user_id,
        email: user.email,
        userType: user.user_type,
      },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    const refreshToken = jwt.sign(
      { userId: user.user_id },
      process.env.JWT_REFRESH_SECRET,
      { expiresIn: "7d" }
    );

    // Optional: Store in memory if you want to track it (like your other logic)
    refreshTokens.add(refreshToken);

    return res.status(200).json({
      success: true,
      accessToken,
      refreshToken,
      user,
    });
  } catch (err) {
    console.error("❌ Facebook login error:", err.response?.data || err);
    return res.status(500).json({ error: "Facebook login failed" });
  }
};
