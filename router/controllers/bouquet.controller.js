const Bouquet =require('../../model/bouquet')


// إضافة باقة جديدة
const addBouquet = async (req, res) => {
  try {
    const { name, price, description, userId } = req.body;

    const imageUrl = req.file ? req.file.path : '';

    const newBouquet = new Bouquet({
      name,
      price,
      description,
      imageUrl,
      userId,
    });

    const savedBouquet = await newBouquet.save();

    res.status(201).json({
      message: 'تمت إضافة الباقة بنجاح',
      bouquet: savedBouquet,
    });
  } catch (error) {
    res.status(500).json({
      message: 'فشل في إضافة الباقة',
      error: error.message,
    });
  }
};

// جلب كل الباقات
const getAllBouquets = async (req, res) => {
  try {
    const bouquets = await Bouquet.find().sort({ createdAt: -1 });
    res.status(200).json(bouquets);
  } catch (error) {
    res.status(500).json({
      message: 'فشل في جلب الباقات',
      error: error.message,
    });
  }
};

// جلب باقات مستخدم معين
const getBouquetsByUser = async (req, res) => {
  try {
    const userId = req.params.userId;
    const bouquets = await Bouquet.find({ userId });
    res.status(200).json(bouquets);
  } catch (error) {
    res.status(500).json({
      message: 'فشل في جلب الباقات',
      error: error.message,
    });
  }
};

// حذف باقة
const deleteBouquet = async (req, res) => {
  try {
    const bouquetId = req.params.id;
    await Bouquet.findByIdAndDelete(bouquetId);
    res.status(200).json({ message: 'تم حذف الباقة بنجاح' });
  } catch (error) {
    res.status(500).json({
      message: 'فشل في حذف الباقة',
      error: error.message,
    });
  }
};

module.exports = {
  addBouquet,
  getAllBouquets,
  getBouquetsByUser,
  deleteBouquet,
};