const Cake = require('../models/Cake');

async function getAllCakes(req, res) {
  try {
    const { category, search } = req.query;
    const filter = {};

    if (category && category !== 'ALL') {
      filter.category = category;
    }

    if (search) {
      const q = search.trim();
      filter.$or = [
        { name: { $regex: q, $options: 'i' } },
        { description: { $regex: q, $options: 'i' } },
      ];
    }

    const cakes = await Cake.find(filter).sort({ name: 1 });
    res.json(cakes.map((c) => c.toPublicJSON()));
  } catch (error) {
    console.error('Get cakes error:', error);
    res.status(500).json({ error: 'Failed to fetch cakes' });
  }
}

async function getCakeById(req, res) {
  try {
    const cake = await Cake.findById(req.params.id);
    if (!cake) {
      return res.status(404).json({ error: 'Cake not found' });
    }
    res.json(cake.toPublicJSON());
  } catch (error) {
    res.status(500).json({ error: 'Failed to fetch cake' });
  }
}

async function createCake(req, res) {
  try {
    const cake = await Cake.create({
      ...req.body,
      rating: req.body.rating || 0,
      inStock: req.body.inStock !== false,
    });
    res.status(201).json(cake.toPublicJSON());
  } catch (error) {
    res.status(500).json({ error: 'Failed to create cake' });
  }
}

async function updateCake(req, res) {
  try {
    const cake = await Cake.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!cake) {
      return res.status(404).json({ error: 'Cake not found' });
    }
    res.json(cake.toPublicJSON());
  } catch (error) {
    res.status(500).json({ error: 'Failed to update cake' });
  }
}

async function deleteCake(req, res) {
  try {
    const cake = await Cake.findByIdAndDelete(req.params.id);
    if (!cake) {
      return res.status(404).json({ error: 'Cake not found' });
    }
    res.json({ message: 'Cake deleted' });
  } catch (error) {
    res.status(500).json({ error: 'Failed to delete cake' });
  }
}

module.exports = {
  getAllCakes,
  getCakeById,
  createCake,
  updateCake,
  deleteCake,
};
