const express = require('express');
const router = express.Router();
const Message = require('../model/Message');

// ✅ إرسال رسالة جديدة
// POST /api/chat/send
router.post('/send', async (req, res) => {
  try {
    const { userId, userName, message, sender } = req.body;

    if (!userId || !message || !sender) {
      return res.status(400).json({ error: 'userId, message, and sender are required' });
    }

    const newMessage = new Message({
      userId,
      userName,
      message,
      sender,
    });

    await newMessage.save();

    res.status(201).json({ success: true, message: 'Message sent successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// ✅ جلب جميع الرسائل بين الأدمن ومستخدم معيّن
// GET /api/chat/:userId
router.get('/:userId', async (req, res) => {
  try {
    const { userId } = req.params;

    const messages = await Message.find({ userId }).sort({ timestamp: 1 });

    res.status(200).json(messages);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

// ✅ جلب جميع المستخدمين الذين راسلوا الأدمن
// GET /api/chat/users
router.get('/users', async (req, res) => {
  try {
    const users = await Message.aggregate([
      {
        $group: {
          _id: "$userId",
          userName: { $first: "$userName" }
        }
      }
    ]);

    res.status(200).json(users);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
