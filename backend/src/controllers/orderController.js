const Order = require('../models/Order');
const CartItem = require('../models/CartItem');
const Cake = require('../models/Cake');
const { clearCart } = require('./cartController');
const { VALID_STATUSES, canTransition } = require('../utils/orderStatus');
const { calculatePromo } = require('../utils/promoOffers');

function generateOrderNumber() {
  return `ORD-${Date.now()}`;
}

async function placeOrder(req, res) {
  try {
    const userId = req.user.id;
    const { deliveryAddress, deliveryDate, paymentMethod, promoCode } = req.body;

    if (!deliveryAddress || !deliveryDate || !paymentMethod) {
      return res.status(400).json({ error: 'Missing delivery or payment info' });
    }

    const cartItems = await CartItem.find({ userId });
    if (cartItems.length === 0) {
      return res.status(400).json({ error: 'Cart is empty' });
    }

    let subtotal = 0;
    const orderItems = [];

    for (const item of cartItems) {
      const cake = await Cake.findById(item.cakeId);
      const cakeName = cake ? cake.name : 'Cake';
      const lineTotal = item.unitPrice * item.quantity;
      subtotal += lineTotal;
      orderItems.push({
        cakeId: item.cakeId,
        cakeName,
        quantity: item.quantity,
        size: item.selectedSize,
        flavor: item.selectedFlavor,
        customMessage: item.customMessage,
        price: lineTotal,
      });
    }

    const pricing = calculatePromo(subtotal, promoCode);
    if (pricing.error) {
      return res.status(400).json({ error: pricing.error });
    }

    const order = await Order.create({
      orderNumber: generateOrderNumber(),
      userId,
      totalAmount: pricing.totalAmount,
      subtotalAmount: pricing.subtotalAmount,
      discountAmount: pricing.discountAmount,
      promoCode: pricing.promoCode,
      status: 'PENDING',
      deliveryAddress,
      deliveryDate,
      paymentMethod,
      items: orderItems,
    });

    await clearCart(userId);
    res.status(201).json(order.toPublicJSON());
  } catch (error) {
    console.error('Place order error:', error);
    res.status(500).json({ error: 'Failed to place order' });
  }
}

async function getOrders(req, res) {
  try {
    const orders = await Order.find({ userId: req.user.id }).sort({ createdAt: -1 });
    res.json(orders.map((o) => o.toPublicJSON()));
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
}

async function getOrderById(req, res) {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }
    if (order.userId.toString() !== req.user.id && req.user.role !== 'ADMIN') {
      return res.status(403).json({ error: 'Access denied' });
    }
    res.json(order.toPublicJSON());
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch order' });
  }
}

async function cancelOrder(req, res) {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }
    if (order.userId.toString() !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }
    if (order.status !== 'PENDING') {
      return res.status(400).json({ error: 'Only pending orders can be cancelled' });
    }
    order.status = 'CANCELLED';
    await order.save();
    res.json({ message: 'Order cancelled' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to cancel order' });
  }
}

async function updateOrderStatus(req, res) {
  try {
    const { status } = req.body;
    if (!VALID_STATUSES.includes(status)) {
      return res.status(400).json({ error: 'Invalid status' });
    }

    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    if (!canTransition(order.status, status)) {
      return res.status(400).json({
        error: `Cannot change status from ${order.status} to ${status}`,
      });
    }

    order.status = status;
    await order.save();
    res.json({ message: 'Status updated', order: order.toPublicJSON() });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update status' });
  }
}

async function getAllOrders(req, res) {
  try {
    const { status, search } = req.query;
    const filter = {};
    if (status && status !== 'ALL') {
      filter.status = status;
    }

    let orders = await Order.find(filter)
      .sort({ createdAt: -1 })
      .populate('userId', 'name email phone');

    if (search && search.trim()) {
      const q = search.trim().toLowerCase();
      orders = orders.filter(
        (o) =>
          o.orderNumber.toLowerCase().includes(q) ||
          (o.userId?.name && o.userId.name.toLowerCase().includes(q)) ||
          (o.userId?.email && o.userId.email.toLowerCase().includes(q)) ||
          o.deliveryAddress.toLowerCase().includes(q)
      );
    }

    res.json(
      orders.map((o) => ({
        ...o.toPublicJSON(),
        customerName: o.userId?.name || 'Unknown',
        customerEmail: o.userId?.email || '',
        customerPhone: o.userId?.phone || '',
      }))
    );
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch orders' });
  }
}

async function submitReview(req, res) {
  try {
    const { rating, comment } = req.body;
    const stars = Number(rating);

    if (!Number.isInteger(stars) || stars < 1 || stars > 5) {
      return res.status(400).json({ error: 'Rating must be between 1 and 5' });
    }

    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }
    if (order.userId.toString() !== req.user.id) {
      return res.status(403).json({ error: 'Access denied' });
    }
    if (order.status !== 'DELIVERED') {
      return res.status(400).json({ error: 'You can review only delivered orders' });
    }

    order.rating = stars;
    order.reviewComment = (comment || '').trim() || null;
    await order.save();

    res.json(order.toPublicJSON());
  } catch (error) {
    console.error('Submit review error:', error);
    res.status(500).json({ error: 'Failed to submit review' });
  }
}

module.exports = {
  placeOrder,
  getOrders,
  getOrderById,
  cancelOrder,
  submitReview,
  updateOrderStatus,
  getAllOrders,
};
