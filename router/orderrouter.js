const express = require("express");
const { Order } = require("../model/usermodel"); // تأكدي إن Order معرف ومصدّر صح
const router = express.Router();

// ✅ إنشاء طلب جديد
router.post("/", async (req, res) => {
  try {
    const { customerName, phone, address, flowers, totalPrice } = req.body;

    if (
      !customerName ||
      !phone ||
      !address ||
      !Array.isArray(flowers) || flowers.length === 0 ||
      totalPrice === undefined || totalPrice === null
    ) {
      return res.status(400).json({ error: "يرجى تعبئة جميع الحقول المطلوبة" });
    }

    const newOrder = new Order(req.body);
    await newOrder.save();
    res.status(201).json({ message: "تم إنشاء الطلب بنجاح", order: newOrder });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ تحديث حالة الطلب (موافقة أو رفض) ← لازم يكون أول قبل "/:id"
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

// ✅ جلب جميع الطلبات الخاصة بمستخدم معيّن
router.get("/user/:userId", async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.params.userId });

    if (!orders || orders.length === 0) {
      return res.status(404).json({ message: "لا توجد طلبات لهذا المستخدم" });
    }

    res.json({ data: orders });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ جلب كل الطلبات
router.get("/", async (req, res) => {
  try {
    const orders = await Order.find();
    res.json(orders);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ جلب طلب معين عبر ID
router.get("/:id", async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) return res.status(404).json({ message: "الطلب غير موجود" });
    res.json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ تحديث طلب عادي
router.put("/:id", async (req, res) => {
  try {
    const updatedOrder = await Order.findByIdAndUpdate(req.params.id, req.body, { new: true });
    if (!updatedOrder) return res.status(404).json({ message: "الطلب غير موجود" });
    res.json({ message: "تم تحديث الطلب", order: updatedOrder });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// ✅ حذف طلب
router.delete("/:id", async (req, res) => {
  try {
    const deletedOrder = await Order.findByIdAndDelete(req.params.id);
    if (!deletedOrder) return res.status(404).json({ message: "الطلب غير موجود" });
    res.json({ message: "تم حذف الطلب بنجاح" });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
