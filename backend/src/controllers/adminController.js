const Order = require('../models/Order');
const User = require('../models/User');
const Cake = require('../models/Cake');

async function getDashboard(req, res) {
  try {
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);

    const [
      totalOrders,
      pendingOrders,
      todayOrders,
      revenueAgg,
      todayRevenueAgg,
      customerCount,
      cakeCount,
      outOfStockCount,
      statusBreakdown,
      recentOrders,
    ] = await Promise.all([
      Order.countDocuments(),
      Order.countDocuments({ status: 'PENDING' }),
      Order.countDocuments({ createdAt: { $gte: startOfDay } }),
      Order.aggregate([
        { $match: { status: { $nin: ['CANCELLED'] } } },
        { $group: { _id: null, total: { $sum: '$totalAmount' } } },
      ]),
      Order.aggregate([
        {
          $match: {
            createdAt: { $gte: startOfDay },
            status: { $nin: ['CANCELLED'] },
          },
        },
        { $group: { _id: null, total: { $sum: '$totalAmount' } } },
      ]),
      User.countDocuments({ role: 'CUSTOMER' }),
      Cake.countDocuments(),
      Cake.countDocuments({ inStock: false }),
      Order.aggregate([{ $group: { _id: '$status', count: { $sum: 1 } } }]),
      Order.find()
        .sort({ createdAt: -1 })
        .limit(5)
        .populate('userId', 'name email phone'),
    ]);

    const breakdown = {};
    statusBreakdown.forEach((s) => {
      breakdown[s._id] = s.count;
    });

    res.json({
      totalOrders,
      pendingOrders,
      todayOrders,
      totalRevenue: revenueAgg[0]?.total || 0,
      todayRevenue: todayRevenueAgg[0]?.total || 0,
      customerCount,
      cakeCount,
      outOfStockCount,
      statusBreakdown: breakdown,
      recentOrders: recentOrders.map((o) => ({
        ...o.toPublicJSON(),
        customerName: o.userId?.name || 'Unknown',
        customerEmail: o.userId?.email || '',
        customerPhone: o.userId?.phone || '',
      })),
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ error: 'Failed to load dashboard' });
  }
}

async function getCustomers(req, res) {
  try {
    const customers = await User.find({ role: 'CUSTOMER' }).sort({ createdAt: -1 });
    const result = await Promise.all(
      customers.map(async (user) => {
        const [orderCount, spentAgg] = await Promise.all([
          Order.countDocuments({ userId: user._id }),
          Order.aggregate([
            { $match: { userId: user._id, status: { $ne: 'CANCELLED' } } },
            { $group: { _id: null, total: { $sum: '$totalAmount' } } },
          ]),
        ]);
        return {
          ...user.toPublicJSON(),
          orderCount,
          totalSpent: spentAgg[0]?.total || 0,
        };
      })
    );
    res.json(result);
  } catch (error) {
    console.error('Get customers error:', error);
    res.status(500).json({ error: 'Failed to fetch customers' });
  }
}

module.exports = { getDashboard, getCustomers };
