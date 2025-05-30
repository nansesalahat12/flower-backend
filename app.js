const express = require("express");
const app = express();

// استيراد المسارات
const orderrouter = require("./router/orderrouter");
const productRouter = require("./router/productRouter");
const flowerrouter = require("./router/flowerrouter");
const bouquetrouters = require("./router/bouquetrouters");
const userRouter = require("./router/userRouter");  // إضافة هذه السطر لاستيراد userRouter
const Product = require("./model/product");

// تأكد من ترتيب استخدام bodyParser قبل أي مسار آخر
app.use(express.json()); // لتحويل البيانات المرسلة إلى JSON

// تحديد المسارات المختلفة
app.use("/api/bouquets", bouquetrouters);  // مسار الباقات
app.use("/api/flowers", flowerrouter);    // مسار الزهور (إذا كنت تستخدمه)
app.use("/api/orders", orderrouter);      // مسار الطلبات
app.use("/api/users", userRouter);  // إضافة هذا المسار لتسجيل الدخول والتسجيل
app.use("/api/products", productRouter);
module.exports = app;
