const mongoose = require('mongoose');

const bouquetSchema = new mongoose.Schema({
  name: String,
  price: Number,
  description: String,
  imageUrl: String,
  userId: String, // حسب ما تستخدمه
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

const Bouquet = mongoose.model('Bouquet', bouquetSchema);
module.exports = Bouquet;
