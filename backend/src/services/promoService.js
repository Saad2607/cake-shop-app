const Promo = require('../models/Promo');

function isExpired(promo) {
  return promo.expiresAt != null && Date.now() > promo.expiresAt;
}

async function findDiscountPromo(code) {
  if (!code || typeof code !== 'string') return null;
  const normalized = code.trim().toUpperCase();
  const promo = await Promo.findOne({ code: normalized, action: 'DISCOUNT', active: true });
  if (!promo || isExpired(promo)) return null;
  return promo;
}

async function calculatePromo(subtotal, promoCode) {
  const trimmed = typeof promoCode === 'string' ? promoCode.trim() : '';
  if (!trimmed) {
    return {
      promoCode: null,
      subtotalAmount: subtotal,
      discountAmount: 0,
      totalAmount: subtotal,
    };
  }

  const promo = await findDiscountPromo(trimmed);
  if (!promo) {
    return { error: 'Invalid or expired promo code' };
  }

  const minOrder = promo.minOrder ?? 0;
  if (subtotal < minOrder) {
    return {
      error: `Minimum order ${minOrder} required for ${promo.code}`,
    };
  }

  const discountAmount =
    Math.round(subtotal * promo.discountPercent * 100) / 100;
  const totalAmount = Math.round((subtotal - discountAmount) * 100) / 100;

  return {
    promoCode: promo.code,
    subtotalAmount: subtotal,
    discountAmount,
    totalAmount,
  };
}

module.exports = { findDiscountPromo, calculatePromo, isExpired };
