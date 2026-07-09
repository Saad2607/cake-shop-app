const mongoose = require('mongoose');

const promoSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    subtitle: { type: String, default: '' },
    tapHint: { type: String, default: 'Tap for details' },
    action: {
      type: String,
      enum: ['DISCOUNT', 'INFO', 'BROWSE_CATEGORY'],
      required: true,
    },
    code: { type: String, trim: true, uppercase: true, default: null },
    discountPercent: { type: Number, default: null, min: 0, max: 1 },
    minOrder: { type: Number, default: null, min: 0 },
    category: {
      type: String,
      enum: ['BIRTHDAY', 'WEDDING', 'CUPCAKE', 'CUSTOM', 'SEASONAL', null],
      default: null,
    },
    infoMessage: { type: String, default: null },
    colorStart: { type: String, default: '#4A1530' },
    colorEnd: { type: String, default: '#8B2D52' },
    accentColor: { type: String, default: '#C9A962' },
    icon: { type: String, default: 'local_offer' },
    expiresAt: { type: Number, default: null },
    active: { type: Boolean, default: true },
    sortOrder: { type: Number, default: 0 },
  },
  { timestamps: true }
);

promoSchema.index({ code: 1 });
promoSchema.index({ active: 1, sortOrder: 1 });

promoSchema.methods.toPublicJSON = function () {
  return {
    id: this._id.toString(),
    title: this.title,
    subtitle: this.subtitle,
    tapHint: this.tapHint,
    action: this.action,
    code: this.code,
    discountPercent: this.discountPercent,
    minOrder: this.minOrder,
    category: this.category,
    infoMessage: this.infoMessage,
    colorStart: this.colorStart,
    colorEnd: this.colorEnd,
    accentColor: this.accentColor,
    icon: this.icon,
    expiresAt: this.expiresAt,
    active: this.active,
    sortOrder: this.sortOrder,
    createdAt: this.createdAt?.getTime(),
  };
};

module.exports = mongoose.model('Promo', promoSchema);
