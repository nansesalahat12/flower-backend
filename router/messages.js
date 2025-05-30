const express = require('express');
const router = express.Router();
const Message = require('../model/Message');

// POST /api/messages/send
router.post('/send', async (req, res) => {
  try {
    const { userId, userName, message } = req.body;

    if (!userId || !message) {
      return res.status(400).json({ error: 'User ID and message are required' });
    }

    const newMessage = new Message({ userId, userName, message });
    await newMessage.save();

    res.status(201).json({ success: true, message: 'Message sent to admin' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

module.exports = router;
