const CartItem = require('../models/CartItem');

async function getCart(req, res) {
  try {
    const items = await CartItem.find({ userId: req.user.id }).populate('cakeId', 'name');
    const publicItems = items.map((item) => {
      const json = item.toPublicJSON();
      const cake = item.cakeId;
      if (cake && typeof cake === 'object' && cake.name) {
        json.cakeId = cake._id.toString();
        json.cakeName = cake.name;
      }
      return json;
    });
    const total = publicItems.reduce((sum, i) => sum + i.unitPrice * i.quantity, 0);
    res.json({ items: publicItems, total });
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch cart' });
  }
}

async function addToCart(req, res) {
  try {
    const { cakeId, quantity, selectedSize, selectedFlavor, customMessage, unitPrice } = req.body;

    if (!cakeId || !selectedSize || !selectedFlavor || unitPrice == null) {
      return res.status(400).json({ error: 'Missing required cart fields' });
    }

    const item = await CartItem.create({
      userId: req.user.id,
      cakeId,
      quantity: quantity || 1,
      selectedSize,
      selectedFlavor,
      customMessage: customMessage || null,
      unitPrice,
    });

    res.status(201).json(item.toPublicJSON());
  } catch (error) {
    res.status(500).json({ error: 'Failed to add to cart' });
  }
}

async function updateCartItem(req, res) {
  try {
    const { quantity } = req.body;
    const item = await CartItem.findOne({ _id: req.params.id, userId: req.user.id });

    if (!item) {
      return res.status(404).json({ error: 'Cart item not found' });
    }

    if (quantity <= 0) {
      await item.deleteOne();
      return res.json({ message: 'Item removed' });
    }

    item.quantity = quantity;
    await item.save();
    res.json({ message: 'Cart updated' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to update cart' });
  }
}

async function removeCartItem(req, res) {
  try {
    const result = await CartItem.deleteOne({ _id: req.params.id, userId: req.user.id });
    if (result.deletedCount === 0) {
      return res.status(404).json({ error: 'Cart item not found' });
    }
    res.json({ message: 'Item removed' });
  } catch (error) {
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
