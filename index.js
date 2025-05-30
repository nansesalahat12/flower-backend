require('dotenv').config(); // تحميل متغيرات البيئة من .env
const express = require('express');
const cors = require('cors'); // <-- ضروري لإزالة مشاكل CORS
const connectDB = require('./db'); // الاتصال بقاعدة البيانات
const userRoutes = require('./router/config/controller/user.router'); // مسارات المستخدمين
const orderRouter = require("./router/orderrouter"); // مسارات الطلبات
const productRouter = require('./router/productRouter'); // مسارات المنتجات
const cartRouter = require('./router/cartRouter');

const app = express();
const PORT = process.env.PORT || 3000;

// الاتصال بقاعدة البيانات;;
connectDB();

// إعدادات الميدلوير
app.use(cors()); // <-- يفعل CORS لجميع الطلبات
app.use(express.json()); // السماح بمعالجة بيانات JSON

// استخدام المسارات
app.use('/users', userRoutes);
app.use('/api/orders', orderRouter);
app.use('/api/products', productRouter);
app.use('/cart', cartRouter);
 // لعرض الصور في المتصفح
const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));
const messageRoutes = require('./router/messages'); // ✅ صح
app.use('/api/messages', messageRoutes);


// تشغيل السيرفر على IP الشبكة المحلية
app.listen(PORT, '0.0.0.0', () => {
  console.log(`✅ Server Running on http://192.168.1.15:${PORT}`);
});