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
      enum: ['PENDING', 'CONFIRMED', 'BAKING', 'READY', 'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED'],
      default: 'PENDING',
    },
    deliveryAddress: { type: String, required: true },
    deliveryDate: { type: Number, required: true },
    paymentMethod: { type: String, required: true },
    items: { type: [orderItemSchema], default: [] },
    rating: { type: Number, min: 1, max: 5, default: null },
    reviewComment: { type: String, default: null },
    deliveryPartnerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', default: null },
    deliveryPartnerName: { type: String, default: null },
    deliveryPartnerPhone: { type: String, default: null },
    deliveryOtp: { type: String, default: null },
  },
  { timestamps: true }
);

orderSchema.methods.toPublicJSON = function () {
  return {
    id: this._id?.toString() || '',
    orderNumber: this.orderNumber || '',
    userId: (this.userId?._id ?? this.userId)?.toString() || '',
    totalAmount: this.totalAmount ?? 0,
    subtotalAmount: this.subtotalAmount ?? this.totalAmount ?? 0,
    discountAmount: this.discountAmount ?? 0,
    promoCode: this.promoCode ?? null,
    status: this.status || 'PENDING',
    deliveryAddress: this.deliveryAddress || '',
    deliveryDate: this.deliveryDate || 0,
    paymentMethod: this.paymentMethod || 'COD',
    rating: this.rating ?? null,
    reviewComment: this.reviewComment ?? null,
    deliveryPartnerId: this.deliveryPartnerId?.toString() || null,
    deliveryPartnerName: this.deliveryPartnerName || null,
    deliveryPartnerPhone: this.deliveryPartnerPhone || null,
    deliveryOtp: this.deliveryOtp || null,
    createdAt: this.createdAt?.getTime() || Date.now(),
    items: (this.items || []).map((item) => ({
      id: item._id?.toString() || '',
      cakeId: item.cakeId ? (item.cakeId._id || item.cakeId).toString() : '',
      cakeName: item.cakeName || 'Artisan Cake',
      quantity: item.quantity || 1,
      size: item.size || '1kg',
      flavor: item.flavor || 'Standard',
      customMessage: item.customMessage || null,
      price: item.price || 0,
    })),
  };
};

module.exports = mongoose.model('Order', orderSchema);
