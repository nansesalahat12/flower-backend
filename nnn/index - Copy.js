require('dotenv').config(); // تحميل متغيرات البيئة من .env
const express = require('express'); // ✅ هذا كان لازم يكون مفعل
const cors = require('cors');
const path = require('path');
const connectDB = require('./db');

const app = express(); // ✅ تعريف التطبيق
const PORT = process.env.PORT || 3000;

// ✅ الاتصال بقاعدة البيانات
connectDB();

// ✅ إعدادات الميدلوير
app.use(cors());
// ❌ لا تضيفي json/urlencoded مع ملفات
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));

// ✅ استدعاء الراوترات
const userRoutes = require('./router/config/controller/user.router');
const orderRouter = require('./router/orderrouter');
const productRouter = require('./router/productRouter');
const cartRouter = require('./router/cartRouter');
const bouquetRouter = require('./router/bouquetrouters');

// ✅ استخدام المسارات
app.use('/users', userRoutes);
app.use('/api/orders', orderRouter);
app.use('/api/products', productRouter);
app.use('/cart', cartRouter);
app.use('/api/bouquets', bouquetRouter);

// ✅ تشغيل السيرفر
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server Running on http://192.168.1.9:${PORT}`);
});
