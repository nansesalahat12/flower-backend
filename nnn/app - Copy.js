const express = require("express");
const app = express();
const cors = require("cors");

const orderrouter = require("./router/orderrouter");
const productRouter = require("./router/productRouter");
const flowerrouter = require("./router/flowerrouter");
const bouquetrouters = require("./router/bouquetrouters");
const userRouter = require("./router/userRouter");

app.use(cors());

// ❌ لا تفعل middleware قراءة body هنا
// app.use(express.json());
// app.use(express.urlencoded({ extended: true }));

app.use("/uploads", express.static("uploads"));

app.use("/api/bouquets", bouquetrouters);
app.use("/api/flowers", flowerrouter);
app.use("/api/orders", orderrouter);
app.use("/api/users", userRouter);
app.use("/api/products", productRouter);

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'حدث خطأ ما، يرجى المحاولة لاحقًا.' });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`✅ Server is running on port ${PORT}`);
});

module.exports = app;
