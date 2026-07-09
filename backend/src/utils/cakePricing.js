/**
 * Server-side price calculation — keep in sync with flutter lib/utils/cake_price.dart
 */
function sizeUnit(size) {
  const s = String(size).trim().toLowerCase();
  const kg = s.match(/^([\d.]+)\s*kg$/);
  if (kg) return parseFloat(kg[1]);

  const g = s.match(/^([\d.]+)\s*g$/);
  if (g) return parseFloat(g[1]) / 1000;

  const pcs = s.match(/^([\d.]+)\s*pcs$/);
  if (pcs) return parseFloat(pcs[1]);

  return 1;
}

function priceForSize(cake, size) {
  if (!cake || !size) return null;
  const sizes = cake.sizes || [];
  if (sizes.length === 0) return cake.basePrice;

  const baseUnit = sizeUnit(sizes[0]);
  const selectedUnit = sizeUnit(size);
  if (baseUnit <= 0) return cake.basePrice;
  return Math.round(cake.basePrice * (selectedUnit / baseUnit));
}

function validateCakeOptions(cake, selectedSize, selectedFlavor) {
  if (!cake) {
    return { ok: false, error: 'Cake not found' };
  }
  if (!cake.inStock) {
    return { ok: false, error: `${cake.name} is currently out of stock` };
  }
  const sizes = cake.sizes || [];
  const flavors = cake.flavors || [];
  if (sizes.length > 0 && !sizes.includes(selectedSize)) {
    return { ok: false, error: 'Invalid size selected' };
  }
  if (flavors.length > 0 && !flavors.includes(selectedFlavor)) {
    return { ok: false, error: 'Invalid flavor selected' };
  }
  return { ok: true };
}

module.exports = { priceForSize, validateCakeOptions };
