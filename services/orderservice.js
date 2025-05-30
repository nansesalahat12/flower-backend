const { orderSchema } = require("../model/order");
const Order = require("../model/orderModel");  // استيراد نموذج الطلب من MongoDB

// جلب جميع الطلبات من قاعدة البيانات
const getAllOrders = async () => {
  try {
    return await Order.find();
  } catch (error) {
    throw new Error("Error fetching orders: " + error.message);
  }
};

// إنشاء طلب جديد
const createOrder = async (orderData) => {
  const { error } = orderSchema.validate(orderData);
  if (error) {
    throw new Error(error.details[0].message);
  }

  try {
    const newOrder = new Order(orderData);
    await newOrder.save();
    return newOrder;
  } catch (error) {
    throw new Error("Error creating order: " + error.message);
  }
};

module.exports = { getAllOrders, createOrder };
