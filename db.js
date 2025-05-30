//db.js

const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    await mongoose.connect('mongodb://localhost:27017/flowers', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ تم الاتصال بقاعدة البيانات MongoDB بنجاح!');
  } catch (error) {
    console.error('❌ خطأ في الاتصال بقاعدة البيانات:', error.message);
    process.exit(1); // إنهاء العملية في حالة وجود خطأ
  }
};

module.exports = connectDB;

