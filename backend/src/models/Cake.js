const mongoose = require('mongoose');

const cakeSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    description: { type: String, default: '' },
    category: {
      type: String,
      enum: ['BIRTHDAY', 'WEDDING', 'CUPCAKE', 'CUSTOM', 'SEASONAL'],
      required: true,
    },
    basePrice: { type: Number, required: true },
    imageUrl: { type: String, default: '' },
    flavors: { type: [String], default: [] },
    sizes: { type: [String], default: [] },
    rating: { type: Number, default: 0 },
    inStock: { type: Boolean, default: true },
  },
  { timestamps: true }
);

cakeSchema.methods.toPublicJSON = function () {
  return {
    id: this._id?.toString() || '',
    name: this.name || '',
    description: this.description || '',
    category: this.category || 'BIRTHDAY',
    basePrice: this.basePrice ?? 0,
    imageUrl: this.imageUrl || '',
    flavors: this.flavors || [],
    sizes: this.sizes || [],
    rating: this.rating ?? 0,
    inStock: this.inStock ?? true,
    createdAt: this.createdAt?.getTime() || Date.now(),
  };
};

module.exports = mongoose.model('Cake', cakeSchema);
