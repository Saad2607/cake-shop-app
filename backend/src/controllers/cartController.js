const mongoose = require('mongoose');
const CartItem = require('../models/CartItem');
const Cake = require('../models/Cake');
const { priceForSize, validateCakeOptions } = require('../utils/cakePricing');
const { isCastError } = require('../utils/errors');

async function getCart(req, res) {
  try {
    const items = await CartItem.find({ userId: req.user.id }).populate('cakeId', 'name');
    const publicItems = [];
    for (const item of items) {
      const cake = item.cakeId;
      if (!cake || typeof cake !== 'object') {
        await item.deleteOne();
        continue;
      }
      const json = item.toPublicJSON();
      json.cakeId = cake._id.toString();
      json.cakeName = cake.name;
      publicItems.push(json);
    }
    const total = publicItems.reduce((sum, i) => sum + i.unitPrice * i.quantity, 0);
    res.json({ items: publicItems, total });
  } catch (error) {
    console.error('Get cart error:', error);
    res.status(500).json({ error: 'Failed to fetch cart' });
  }
}

async function addToCart(req, res) {
  try {
    const { cakeId, quantity, selectedSize, selectedFlavor, customMessage, unitPrice } = req.body;

    if (!cakeId || !selectedSize || !selectedFlavor || unitPrice == null) {
      return res.status(400).json({ error: 'Missing required cart fields' });
    }

    if (!mongoose.isValidObjectId(cakeId)) {
      return res.status(400).json({ error: 'Invalid cake id' });
    }

    const qty = Number(quantity);
    if (!Number.isInteger(qty) || qty < 1) {
      return res.status(400).json({ error: 'Quantity must be at least 1' });
    }

    const cake = await Cake.findById(cakeId);
    const validation = validateCakeOptions(cake, selectedSize, selectedFlavor);
    if (!validation.ok) {
      return res.status(400).json({ error: validation.error });
    }

    const expectedPrice = priceForSize(cake, selectedSize);
    if (Math.abs(Number(unitPrice) - expectedPrice) > 0.01) {
      return res.status(400).json({ error: 'Price mismatch — refresh and try again' });
    }

    const item = await CartItem.create({
      userId: req.user.id,
      cakeId,
      quantity: qty,
      selectedSize,
      selectedFlavor,
      customMessage: customMessage || null,
      unitPrice: expectedPrice,
    });

    res.status(201).json(item.toPublicJSON());
  } catch (error) {
    console.error('Add to cart error:', error);
    res.status(500).json({ error: 'Failed to add to cart' });
  }
}

async function updateCartItem(req, res) {
  try {
    const { quantity } = req.body;
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(404).json({ error: 'Cart item not found' });
    }

    const qty = Number(quantity);
    if (!Number.isInteger(qty)) {
      return res.status(400).json({ error: 'Quantity must be a whole number' });
    }

    const item = await CartItem.findOne({ _id: req.params.id, userId: req.user.id });

    if (!item) {
      return res.status(404).json({ error: 'Cart item not found' });
    }

    if (qty <= 0) {
      await item.deleteOne();
      return res.json({ message: 'Item removed' });
    }

    item.quantity = qty;
    await item.save();
    res.json({ message: 'Cart updated' });
  } catch (error) {
    if (isCastError(error)) {
      return res.status(404).json({ error: 'Cart item not found' });
    }
    console.error('Update cart error:', error);
    res.status(500).json({ error: 'Failed to update cart' });
  }
}

async function removeCartItem(req, res) {
  try {
    if (!mongoose.isValidObjectId(req.params.id)) {
      return res.status(404).json({ error: 'Cart item not found' });
    }
    const result = await CartItem.deleteOne({ _id: req.params.id, userId: req.user.id });
    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Cart item not found' });
    }
    res.json({ message: 'Item removed' });
  } catch (error) {
    if (isCastError(error)) {
      return res.status(404).json({ error: 'Cart item not found' });
    }
    res.status(500).json({ error: 'Failed to remove item' });
  }
}

async function clearCart(userId) {
  await CartItem.deleteMany({ userId });
}

module.exports = {
  getCart,
  addToCart,
  updateCartItem,
  removeCartItem,
  clearCart,
};
