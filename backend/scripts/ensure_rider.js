require('dotenv').config();
const bcrypt = require('bcryptjs');
const { connectDatabase } = require('../src/config/database');
const User = require('../src/models/User');

async function ensureRider() {
  try {
    await connectDatabase();
    const email = 'rider@cakeshop.com';
    let user = await User.findOne({ email });
    if (!user) {
      user = await User.create({
        name: 'Ramesh (Delivery Partner)',
        email,
        phone: '+919876543212',
        passwordHash: await bcrypt.hash('rider123', 10),
        role: 'RIDER',
      });
      console.log('Rider user created:', user._id);
    } else {
      user.role = 'RIDER';
      await user.save();
      console.log('Rider user updated to RIDER role:', user._id);
    }
    process.exit(0);
  } catch (err) {
    console.error('Error ensuring rider:', err);
    process.exit(1);
  }
}

ensureRider();
