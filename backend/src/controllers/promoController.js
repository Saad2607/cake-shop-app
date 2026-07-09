const mongoose = require('mongoose');
const Promo = require('../models/Promo');
const Order = require('../models/Order');
const { isExpired } = require('../services/promoService');
const { isCastError } = require('../utils/errors');

async function getActivePromos(req, res) {
  try {
    const promos = await Promo.find({ active: true }).sort({ sortOrder: 1, createdAt: -1 });
    const active = promos
      .filter((p) => !isExpired(p))
      .map((p) => p.toPublicJSON());
    res.json(active);
  } catch (error) {
    console.error('Get promos error:', error);
    res.status(500).json({ error: 'Failed to fetch promos' });
  }
}

async function getAllPromosAdmin(req, res) {
  try {
    const [promos, usageAgg] = await Promise.all([
      Promo.find().sort({ sortOrder: 1, createdAt: -1 }),
      Order.aggregate([
        { $match: { promoCode: { $ne: null } } },
        {
          $group: {
            _id: '$promoCode',
            useCount: { $sum: 1 },
            totalDiscount: { $sum: '$discountAmount' },
          },
        },
      ]),
    ]);

    const usageByCode = {};
    usageAgg.forEach((row) => {
      usageByCode[row._id] = {
        useCount: row.useCount,
        totalDiscount: row.totalDiscount || 0,
      };
    });

    res.json(
      promos.map((p) => {
        const json = p.toPublicJSON();
        const usage = p.code ? usageByCode[p.code] : null;
        return {
          ...json,
          useCount: usage?.useCount ?? 0,
          totalDiscount: usage?.totalDiscount ?? 0,
        };
      })
    );
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch promos' });
  }
}

async function createPromo(req, res) {
  try {
    const body = normalizeBody(req.body);
    if (body.action === 'DISCOUNT' && !body.code) {
      return res.status(400).json({ error: 'Discount promos require a code' });
    }
    if (body.code) {
      const exists = await Promo.findOne({ code: body.code });
      if (exists) {
        return res.status(400).json({ error: 'Promo code already exists' });
      }
    }
    const promo = await Promo.create(body);
    res.status(201).json(promo.toPublicJSON());
  } catch (error) {
    console.error('Create promo error:', error);
    res.status(500).json({ error: 'Failed to create promo' });
  }
}

async function updatePromo(req, res) {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(404).json({ error: 'Promo not found' });
    }
    const body = normalizeBody(req.body);
    if (body.code) {
      const exists = await Promo.findOne({
        code: body.code,
        _id: { $ne: req.params.id },
      });
      if (exists) {
        return res.status(400).json({ error: 'Promo code already exists' });
      }
    }
    const promo = await Promo.findByIdAndUpdate(req.params.id, body, { new: true });
    if (!promo) {
      return res.status(404).json({ error: 'Promo not found' });
    }
    res.json(promo.toPublicJSON());
  } catch (error) {
    if (isCastError(error)) {
      return res.status(404).json({ error: 'Promo not found' });
    }
    res.status(500).json({ error: 'Failed to update promo' });
  }
}

async function deletePromo(req, res) {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(404).json({ error: 'Promo not found' });
    }
    const promo = await Promo.findByIdAndDelete(req.params.id);
    if (!promo) {
      return res.status(404).json({ error: 'Promo not found' });
    }
    res.json({ message: 'Promo deleted' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete promo' });
  }
}

function normalizeBody(body) {
  const data = { ...body };
  if (data.code) data.code = String(data.code).trim().toUpperCase();
  if (data.discountPercent != null) data.discountPercent = Number(data.discountPercent);
  if (data.minOrder != null) data.minOrder = Number(data.minOrder);
  if (data.expiresAt === '' || data.expiresAt === null) data.expiresAt = null;
  if (data.expiresAt != null) data.expiresAt = Number(data.expiresAt);
  if (data.sortOrder != null) data.sortOrder = Number(data.sortOrder);
  if (data.active != null) data.active = Boolean(data.active);
  return data;
}

module.exports = {
  getActivePromos,
  getAllPromosAdmin,
  createPromo,
  updatePromo,
  deletePromo,
};
