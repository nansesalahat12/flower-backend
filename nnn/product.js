const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true
  },
  price: {
    type: Number,
    required: true
  },
  description: {
    type: String,
    trim: true
  },
  imageUrl: {
    type: String,
    required: true
  },
  category: {
    type: String,
    required: true
  },
  color: {
    type: String,
    required: true
  },
  stock: {
    type: Number,
    default: 0
  },
  top_pick: {
    type: Boolean,
    default: false
  },
  exclusive: {
    type: Boolean,
    default: false
  },
  best_seller: {
    type: Boolean,
    default: false
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

const Product = mongoose.models.Product || mongoose.model('Product', productSchema);
module.exports = Product;
