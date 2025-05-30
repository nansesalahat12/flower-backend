// controllers/product_controller.js

const Product = require('../models/product_model');

// دالة البحث عن المنتجات حسب اللون
exports.searchByColor = async (req, res) => {
  try {
    const color = req.query.color;
    const products = await Product.find({ color: color });

    if (products.length === 0) {
      return res.status(404).json({ message: 'لم يتم العثور على منتجات بهذا اللون' });
    }

    res.status(200).json({ data: products });
  } catch (error) {
    res.status(500).json({ message: 'حدث خطأ في الخادم' });
  }
};
