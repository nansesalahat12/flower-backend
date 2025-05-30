const express = require('express');
const router = express.Router();
const Product = require('../model/product');
const multer = require('multer');
const path = require('path');

// إعداد multer لتخزين الصور
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/'); // مجلد الصور
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname)); // اسم فريد للصورة
  }
});

const upload = multer({ storage });

// --- إضافة منتج جديد مع رفع صورة ---
router.post('/', upload.single('image'), async (req, res) => {
  try {
    const imageUrl = req.file ? req.file.filename : '';

    const newProduct = new Product({
      name: req.body.name,
      price: req.body.price,
      description: req.body.description,
      imageUrl: imageUrl, // فقط اسم الصورة
      category: req.body.category,
      color: req.body.color,
      exclusive: req.body.exclusive === 'true',
      best_seller: req.body.best_seller === 'true',
      top_pick: req.body.top_pick === 'true',
      stock: req.body.stock || 0,
    });

    await newProduct.save();
    res.status(201).json({ message: "تم إضافة المنتج", data: newProduct });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
});

// --- عرض المنتجات مع فلترة حسب الخصائص ---
router.get('/', async (req, res) => {
  try {
    const filter = {};

    if (req.query.exclusive === 'true') filter.exclusive = true;
    if (req.query.best_seller === 'true') filter.best_seller = true;
    if (req.query.top_pick === 'true') filter.top_pick = true;

    if (req.query.category) {
      filter.category = { $regex: req.query.category.trim(), $options: 'i' };
    }

    if (req.query.color) {
      filter.color = { $regex: req.query.color.trim(), $options: 'i' };
    }

    console.log('🔍 فلتر البحث:', filter);

    const products = await Product.find(filter);
    res.status(200).json({ data: products });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- 🔍 البحث العام في الاسم، الوصف، اللون، الفئة ---
router.get('/search', async (req, res) => {
  try {
    const query = req.query.query || '';

    const products = await Product.find({
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } },
        { color: { $regex: query, $options: 'i' } },
        { category: { $regex: query, $options: 'i' } },
      ],
    });

    res.status(200).json({ data: products });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
