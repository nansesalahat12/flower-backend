const mongoose = require('mongoose');

// ✅ لازم يبدأ بالتعريف
const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  phone: { type: String, required: true },
  address: { type: String, required: true },
  email: { type: String, required: true, unique: true },
  city: { type: String, required: true },
  password: { type: String, required: true }
});

const orderSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  customerName: { type: String, required: true },
  phone: { type: String, required: true },
  address: { type: String, required: true },
  flowers: [
    {
      productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
      flowerName: String,
      quantity: Number,
      price: Number
    }
  ],
  totalPrice: { type: Number, required: true },
  paymentMethod: { type: String },
  deliveryDate: { type: Date },
  notes: { type: String },
 status: {
  type: String,
  enum: ["pending", "approved", "rejected"], // 🟢 حالات واضحة ومتناسقة
  default: "pending"
}

}, { timestamps: true });

const productSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  price: { type: Number, required: true },
  description: { type: String, trim: true },
  imageUrl: { type: String, required: true },
  category: { type: String, required: true },
  subcategory: { type: String },
  stock: { type: Number, default: 0 },
  color: { type: String, required: true },
  top_pick: { type: Boolean, default: false },
  exclusive: { type: Boolean, default: false },
  best_seller: { type: Boolean, default: false },
  ratings: [{
    user: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    rating: { type: Number, min: 1, max: 5 },
    comment: { type: String }
  }],
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

// ✅ التأكد من ترتيب التعريف قبل الاستخدام
const User = mongoose.models.User || mongoose.model('User', userSchema);
const Order = mongoose.models.Order || mongoose.model('Order', orderSchema);
const Product = mongoose.models.Product || mongoose.model('Product', productSchema);

module.exports = { User, Order, Product };
