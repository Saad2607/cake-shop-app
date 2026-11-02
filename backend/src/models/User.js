const mongoose = require('mongoose');

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    phone: { type: String, required: true, trim: true },
    passwordHash: { type: String, required: true },
    role: { type: String, enum: ['CUSTOMER', 'ADMIN', 'RIDER'], default: 'CUSTOMER' },
  },
  { timestamps: true }
);

userSchema.methods.toPublicJSON = function () {
  return {
    id: this._id?.toString() || '',
    name: this.name || '',
    email: this.email || '',
    phone: this.phone || '',
    role: this.role || 'CUSTOMER',
    createdAt: this.createdAt?.getTime() || Date.now(),
  };
};

module.exports = mongoose.model('User', userSchema);
