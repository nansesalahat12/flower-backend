// routes/cartRouter.js

const express = require('express');
const router = express.Router();
const cartService = require('../services/cartService');

// 🛒 جلب السلة لمستخدم
router.get('/:userId', async (req, res) => {
  try {
    const cart = await cartService.getCartByUserId(req.params.userId);
    if (!cart) {
      // ✅ بدل ما نرجع 404 نرجع سلة فاضية لتجنب فشل التطبيق
      return res.status(200).json({ userId: req.params.userId, items: [] });
    }
    res.status(200).json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ➕ إضافة منتج للسلة
router.post('/add', async (req, res) => {
  try {
    const { userId, productId, quantity } = req.body;
    if (!userId || !productId || !quantity) {
      return res.status(400).json({ error: 'بيانات ناقصة' });
    }

    const cart = await cartService.addToCart(userId, productId, quantity);
    res.status(201).json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ❌ حذف منتج من السلة باستخدام userId + productId
router.delete('/remove', async (req, res) => {
  try {
    const { userId, productId } = req.body;
    if (!userId || !productId) {
      return res.status(400).json({ error: 'بيانات ناقصة' });
    }

    const cart = await cartService.removeFromCart(userId, productId);
    res.json(cart);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 🧹 مسح السلة بالكامل
router.delete('/clear/:userId', async (req, res) => {
  try {
    const result = await cartService.clearCart(req.params.userId);
    if (!result) return res.status(404).json({ message: 'السلة غير موجودة' });
    res.json({ message: 'تم حذف السلة بالكامل', result });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
