const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  userName: { type: String },
  message: { type: String, required: true },
  response: { type: String }, // ✅ رد الأدمن
  timestamp: { type: Date, default: Date.now },
  respondedAt: { type: Date } // ✅ وقت الرد
});

const Message = mongoose.models.Message || mongoose.model('Message', messageSchema);
module.exports = Message;
