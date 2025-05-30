const express = require('express');
const router = express.Router();
const { Product } = require('../model/product');
const multer = require('multer');
const { v2: cloudinary } = require('cloudinary');
const { CloudinaryStorage } = require('multer-storage-cloudinary');
require('dotenv').config();

// 📦 تأكيد تحميل الملف
console.log("🔥 productRouter.js file loaded");

// ✅ Cloudinary إعداد
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// ✅ التخزين في Cloudinary
const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: 'products',
    allowed_formats: ['jpg', 'jpeg', 'png'],
  },
});

const upload = multer({ storage });

// ✅ تأكيد الدخول على الراوتر
router.use((req, res, next) => {
  console.log("🚀 دخل فعليًا على راوتر /api/products");
  next();
});

// ✅ إضافة منتج جديد مع صورة
router.post('/', upload.single('image'), async (req, res) => {
  try {
    console.log("📨 Content-Type:", req.headers['content-type']);
    console.log("📥 req.body:", req.body);
    console.log("🖼️ req.file:", req.file);

    if (!req.body || !req.file) {
      return res.status(400).json({ error: "البيانات أو الصورة مفقودة" });
    }

    const { name, price, description, category, color, stock } = req.body;
    const imageUrl = req.file.path || req.file.secure_url || req.file.url;

    const newProduct = new Product({
      name,
      price,
      description,
      category,
      color,
      stock,
      imageUrl,
    });

    await newProduct.save();

    res.status(201).json({ message: "✅ تم إضافة المنتج", product: newProduct });

  } catch (error) {
    console.error("❌ خطأ أثناء إضافة المنتج:", error.message);
    res.status(500).json({ error: "حدث خطأ أثناء الإضافة", details: error.message });
  }
});

module.exports = router;