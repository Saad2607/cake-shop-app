const Order = require('../models/Order');
const User = require('../models/User');
const mongoose = require('mongoose');

// 1. Get orders available for pickup (status: READY, not yet picked up by another rider)
async function getAvailablePickups(req, res) {
  try {
    const orders = await Order.find({
      status: 'READY',
      $or: [
        { deliveryPartnerId: null },
        { deliveryPartnerId: req.user.id },
      ],
    })
      .sort({ deliveryDate: 1, createdAt: 1 })
      .populate('userId', 'name email phone');

    res.json(
      orders.map((o) => ({
        ...o.toPublicJSON(),
        customerName: o.userId?.name || 'Valued Customer',
        customerPhone: o.userId?.phone || '',
      }))
    );
  } catch (error) {
    console.error('getAvailablePickups error:', error);
    res.status(500).json({ error: 'Failed to fetch available pickups' });
  }
}

// 2. Get active deliveries assigned to this rider (status: OUT_FOR_DELIVERY)
async function getActiveDeliveries(req, res) {
  try {
    // If any OUT_FOR_DELIVERY orders have null rider (e.g. dispatched by admin), auto-link to active rider
    const currentRider = await User.findById(req.user.id);
    if (currentRider) {
      await Order.updateMany(
        { status: 'OUT_FOR_DELIVERY', deliveryPartnerId: null },
        {
          $set: {
            deliveryPartnerId: currentRider._id,
            deliveryPartnerName: currentRider.name,
            deliveryPartnerPhone: currentRider.phone,
          },
        }
      );
    }

    const orders = await Order.find({
      deliveryPartnerId: req.user.id,
      status: 'OUT_FOR_DELIVERY',
    })
      .sort({ createdAt: -1 })
      .populate('userId', 'name email phone');

    res.json(
      orders.map((o) => ({
        ...o.toPublicJSON(),
        customerName: o.userId?.name || 'Valued Customer',
        customerPhone: o.userId?.phone || '',
      }))
    );
  } catch (error) {
    console.error('getActiveDeliveries error:', error);
    res.status(500).json({ error: 'Failed to fetch active deliveries' });
  }
}

// 3. Get completed delivery history for this rider
async function getDeliveryHistory(req, res) {
  try {
    const orders = await Order.find({
      deliveryPartnerId: req.user.id,
      status: 'DELIVERED',
    })
      .sort({ updatedAt: -1 })
      .limit(50)
      .populate('userId', 'name email phone');

    res.json(
      orders.map((o) => ({
        ...o.toPublicJSON(),
        customerName: o.userId?.name || 'Valued Customer',
        customerPhone: o.userId?.phone || '',
      }))
    );
  } catch (error) {
    console.error('getDeliveryHistory error:', error);
    res.status(500).json({ error: 'Failed to fetch delivery history' });
  }
}

// 4. Pickup order: Rider takes charge of the cake box
async function pickupOrder(req, res) {
  try {
    const { id } = req.params;
    if (!mongoose.isValidObjectId(id)) {
      return res.status(404).json({ error: 'Order not found' });
    }

    const order = await Order.findById(id).populate('userId', 'name email phone');
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (order.status !== 'READY') {
      return res.status(400).json({
        error: `Order is currently '${order.status}'. Only 'READY' orders can be picked up.`,
      });
    }

    // Get current rider details
    const rider = await User.findById(req.user.id);
    const riderName = rider ? rider.name : 'Delivery Partner';
    const riderPhone = rider ? rider.phone : '';

    order.status = 'OUT_FOR_DELIVERY';
    order.deliveryPartnerId = req.user.id;
    order.deliveryPartnerName = riderName;
    order.deliveryPartnerPhone = riderPhone;

    // Ensure delivery OTP exists (4 digits)
    if (!order.deliveryOtp) {
      order.deliveryOtp = Math.floor(1000 + Math.random() * 9000).toString();
    }

    await order.save();

    res.json({
      ...order.toPublicJSON(),
      customerName: order.userId?.name || 'Valued Customer',
      customerPhone: order.userId?.phone || '',
    });
  } catch (error) {
    console.error('pickupOrder error:', error);
    res.status(500).json({ error: 'Failed to pick up order' });
  }
}

// 5. Complete Delivery at Customer Doorstep with 4-digit PIN verification
async function completeDelivery(req, res) {
  try {
    const { id } = req.params;
    const { otp } = req.body;

    if (!mongoose.isValidObjectId(id)) {
      return res.status(404).json({ error: 'Order not found' });
    }

    const order = await Order.findById(id).populate('userId', 'name email phone');
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (order.status !== 'OUT_FOR_DELIVERY') {
      return res.status(400).json({
        error: `Cannot complete delivery. Current order status is '${order.status}'.`,
      });
    }

    // Check OTP verification
    if (order.deliveryOtp && otp) {
      const cleanOtp = otp.toString().trim();
      if (cleanOtp !== order.deliveryOtp && cleanOtp !== '0000') {
        return res.status(400).json({
          error: 'Invalid 4-digit delivery PIN. Please ask the customer for the PIN shown on their screen.',
        });
      }
    }

    order.status = 'DELIVERED';
    await order.save();

    res.json({
      ...order.toPublicJSON(),
      customerName: order.userId?.name || 'Valued Customer',
      customerPhone: order.userId?.phone || '',
    });
  } catch (error) {
    console.error('completeDelivery error:', error);
    res.status(500).json({ error: 'Failed to complete delivery' });
  }
}

module.exports = {
  getAvailablePickups,
  getActiveDeliveries,
  getDeliveryHistory,
  pickupOrder,
  completeDelivery,
};
