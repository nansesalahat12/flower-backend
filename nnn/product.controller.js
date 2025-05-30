const Product = require('../model/product');

const addProduct = async (req, res) => {
  try {
    console.log("📦 BODY:", req.body);
    console.log("🖼️ FILE:", req.file);

    const imageUrl = req.file ? req.file.path : '';

    const newProduct = new Product({
      name: req.body.name,
      price: req.body.price,
      description: req.body.description,
      imageUrl,
      category: req.body.category,
      color: req.body.color,
      stock: req.body.stock,
    });

    await newProduct.save();
    res.status(201).json({ message: 'تم إضافة المنتج بنجاح', data: newProduct });

  } catch (error) {
    res.status(500).json({
      error: error.toString(),
      stack: error.stack,
    });
  }
};

const getAllProducts = async (req, res) => {
  try {
    const category = req.query.category;
    let filter = category ? { category } : {};
    const products = await Product.find(filter);
    res.status(200).json({ data: products });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const searchByColor = async (req, res) => {
  try {
    const color = req.query.color;
    const products = await Product.find({
      color: { $regex: new RegExp(color, 'i') }
    });
    res.status(200).json({ data: products });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const searchProducts = async (req, res) => {
  try {
    const query = req.query.query;
    if (!query) {
      return res.status(400).json({ error: 'يرجى إدخال كلمة البحث' });
    }

    const products = await Product.find({
      $or: [
        { name: { $regex: query, $options: 'i' } },
        { color: { $regex: query, $options: 'i' } },
        { description: { $regex: query, $options: 'i' } },
      ],
    });

    res.status(200).json({ data: products });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

const updateProduct = async (req, res) => {
  try {
    const { id } = req.params;

    const updatedProduct = await Product.findByIdAndUpdate(
      id,
      {
        ...(req.body.name && { name: req.body.name }),
        ...(req.body.price && { price: req.body.price }),
        ...(req.body.description && { description: req.body.description }),
        ...(req.body.category && { category: req.body.category }),
        ...(req.body.color && { color: req.body.color }),
        ...(req.body.top_pick !== undefined && { top_pick: req.body.top_pick }),
        ...(req.body.exclusive !== undefined && { exclusive: req.body.exclusive }),
        ...(req.body.best_seller !== undefined && { best_seller: req.body.best_seller }),
      },
      { new: true }
    );

    if (!updatedProduct) {
      return res.status(404).json({ message: 'المنتج غير موجود' });
    }

    res.status(200).json({ message: 'تم التحديث بنجاح', data: updatedProduct });
  } catch (error) {
    res.status(400).json({ error: error.message });
  }
};

module.exports = {
  addProduct,
  getAllProducts,
  searchByColor,
  searchProducts,
  updateProduct,
};
