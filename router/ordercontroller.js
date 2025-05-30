const express = require("express");
const { Order } = require("../model/usermodel");
const router = express.Router();

// ✅ إنشاء طلب جديد مع حالة "pending" تلقائيًا
router.post("/", async (req, res) => {
  try {
    const newOrder = new Order({
      ...req.body,
      status: "pending", // 👈 الحالة الابتدائية
    });
    await newOrder.save();
    res.status(201).json({ message: "تم إنشاء الطلب بنجاح", order: newOrder });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ تحديث حالة الطلب (موافقة أو رفض) - لازم يكون قبل "/:id"
router.put("/approve", async (req, res) => {
  const { orderId, status } = req.body;

  if (!orderId || !status) {
    return res.status(400).json({ message: "مطلوب معرف الطلب والحالة" });
  }

  try {
    const updatedOrder = await Order.findByIdAndUpdate(
      orderId,
      { status },
      { new: true }
    );

    if (!updatedOrder) {
      return res.status(404).json({ message: "الطلب غير موجود" });
    }

    res.json({ message: "تم تحديث حالة الطلب", order: updatedOrder });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ جلب جميع الطلبات
router.get("/", async (req, res) => {
  try {
    const orders = await Order.find();
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ جلب طلب معين حسب ID
router.get("/:id", async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "الطلب غير موجود" });
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ تحديث بيانات طلب معين
router.put("/:id", async (req, res) => {
  try {
    const updatedOrder = await Order.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!updatedOrder)
      return res.status(404).json({ message: "الطلب غير موجود" });
    res.json({ message: "تم تحديث الطلب", order: updatedOrder });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ حذف طلب
router.delete("/:id", async (req, res) => {
  try {
    const deletedOrder = await Order.findByIdAndDelete(req.params.id);
    if (!deletedOrder)
      return res.status(404).json({ message: "الطلب غير موجود" });
    res.json({ message: "تم حذف الطلب بنجاح" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
