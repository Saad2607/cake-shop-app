/**
 * Promo codes — keep in sync with flutter lib/utils/promo_offers.dart
 */
const PROMO_OFFERS = [
  {
    code: 'SWEET50',
    discountPercent: 0.5,
    minOrder: 999,
  },
];

function findPromo(code) {
  if (!code || typeof code !== 'string') return null;
  const normalized = code.trim().toUpperCase();
  return PROMO_OFFERS.find((p) => p.code === normalized) || null;
}

function calculatePromo(subtotal, promoCode) {
  const promo = findPromo(promoCode);
  if (!promo) {
    return {
      promoCode: null,
      subtotalAmount: subtotal,
      discountAmount: 0,
      totalAmount: subtotal,
    };
  }
  if (subtotal < promo.minOrder) {
    return {
      error: `Minimum order ${promo.minOrder} required for ${promo.code}`,
    };
  }
  const discountAmount = Math.round(subtotal * promo.discountPercent * 100) / 100;
  const totalAmount = Math.round((subtotal - discountAmount) * 100) / 100;
  return {
    promoCode: promo.code,
    subtotalAmount: subtotal,
    discountAmount,
    totalAmount,
  };
}

module.exports = { findPromo, calculatePromo };
