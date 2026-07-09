/**
 * Promo codes — keep in sync with flutter lib/utils/promo_offers.dart
 */
const PROMO_OFFERS = [
  {
    code: 'SWEET50',
    discountPercent: 0.5,
    minOrder: 999,
    expiresAt: new Date('2026-07-10T23:59:59.000Z').getTime(),
  },
];

function findPromo(code) {
  if (!code || typeof code !== 'string') return null;
  const normalized = code.trim().toUpperCase();
  const promo = PROMO_OFFERS.find((p) => p.code === normalized);
  if (!promo) return null;
  if (promo.expiresAt && Date.now() > promo.expiresAt) return null;
  return promo;
}

function calculatePromo(subtotal, promoCode) {
  const trimmed = typeof promoCode === 'string' ? promoCode.trim() : '';
  if (trimmed) {
    const promo = findPromo(trimmed);
    if (!promo) {
      return { error: 'Invalid or expired promo code' };
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

  return {
    promoCode: null,
    subtotalAmount: subtotal,
    discountAmount: 0,
    totalAmount: subtotal,
  };
}

module.exports = { findPromo, calculatePromo };
