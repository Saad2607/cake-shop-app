const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema(
  {
    cakeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Cake', required: true },
    cakeName: { type: String, required: true },
    quantity: { type: Number, required: true },
    size: { type: String, required: true },
    flavor: { type: String, required: true },
    customMessage: { type: String, default: null },
    price: { type: Number, required: true },
  },
  { _id: true }
);

const orderSchema = new mongoose.Schema(
  {
    orderNumber: { type: String, required: true, unique: true },
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    totalAmount: { type: Number, required: true },
    subtotalAmount: { type: Number },
    discountAmount: { type: Number, default: 0 },
    promoCode: { type: String, default: null },
    status: {
      type: String,
      enum: ['PENDING', 'CONFIRMED', 'BAKING', 'READY', 'DELIVERED', 'CANCELLED'],
      default: 'PENDING',
    },
    deliveryAddress: { type: String, required: true },
    deliveryDate: { type: Number, required: true },
    paymentMethod: { type: String, required: true },
    items: { type: [orderItemSchema], default: [] },
    rating: { type: Number, min: 1, max: 5, default: null },
    reviewComment: { type: String, default: null },
  },
  { timestamps: true }
);

orderSchema.methods.toPublicJSON = function () {
  return {
    id: this._id.toString(),
    orderNumber: this.orderNumber,
    userId: this.userId.toString(),
    totalAmount: this.totalAmount,
    subtotalAmount: this.subtotalAmount ?? this.totalAmount,
    discountAmount: this.discountAmount ?? 0,
    promoCode: this.promoCode ?? null,
    status: this.status,
    deliveryAddress: this.deliveryAddress,
    deliveryDate: this.deliveryDate,
    paymentMethod: this.paymentMethod,
    rating: this.rating ?? null,
    reviewComment: this.reviewComment ?? null,
    createdAt: this.createdAt?.getTime(),
    items: this.items.map((item) => ({
      id: item._id.toString(),
      cakeId: item.cakeId.toString(),
      cakeName: item.cakeName,
      quantity: item.quantity,
      size: item.size,
      flavor: item.flavor,
      customMessage: item.customMessage,
      price: item.price,
    })),
  };
};

module.exports = mongoose.model('Order', orderSchema);
