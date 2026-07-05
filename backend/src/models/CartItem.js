const mongoose = require('mongoose');

const cartItemSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    cakeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Cake', required: true },
    quantity: { type: Number, required: true, default: 1, min: 1 },
    selectedSize: { type: String, required: true },
    selectedFlavor: { type: String, required: true },
    customMessage: { type: String, default: null },
    unitPrice: { type: Number, required: true },
  },
  { timestamps: true }
);

cartItemSchema.methods.toPublicJSON = function () {
  return {
    id: this._id.toString(),
    cakeId: this.cakeId.toString(),
    quantity: this.quantity,
    selectedSize: this.selectedSize,
    selectedFlavor: this.selectedFlavor,
    customMessage: this.customMessage,
    unitPrice: this.unitPrice,
    createdAt: this.createdAt?.getTime(),
  };
};

module.exports = mongoose.model('CartItem', cartItemSchema);
