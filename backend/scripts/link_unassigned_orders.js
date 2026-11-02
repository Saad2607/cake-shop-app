require('dotenv').config();
const mongoose = require('mongoose');
const Order = require('../src/models/Order');
const User = require('../src/models/User');

async function run() {
  await mongoose.connect(process.env.MONGODB_URI);
  const rider = await User.findOne({ role: 'RIDER' });
  if (!rider) {
    console.log('No rider found');
    process.exit(1);
  }
  const res = await Order.updateMany(
    { status: 'OUT_FOR_DELIVERY', deliveryPartnerId: null },
    {
      $set: {
        deliveryPartnerId: rider._id,
        deliveryPartnerName: rider.name,
        deliveryPartnerPhone: rider.phone,
      },
    }
  );
  console.log('Updated orders count:', res.modifiedCount);
  const updatedOrders = await Order.find({ status: 'OUT_FOR_DELIVERY' });
  console.log('Active OUT_FOR_DELIVERY orders now:', updatedOrders.map(o => ({
    number: o.orderNumber,
    partnerName: o.deliveryPartnerName,
    partnerPhone: o.deliveryPartnerPhone,
    otp: o.deliveryOtp,
  })));
  process.exit(0);
}

run().catch(err => {
  console.error(err);
  process.exit(1);
});
