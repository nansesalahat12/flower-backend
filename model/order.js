// models/order.js

const Joi = require("joi");

// تعريف المخطط باستخدام Joi
const orderSchema = Joi.object({
  flowerType: Joi.string().required(),
  bouquetSize: Joi.string().valid("Small", "Medium", "Large").required(),
  wrapping: Joi.string().valid("Standard", "Premium").required(),
  decoration: Joi.string().optional(),
  customerName: Joi.string().required(),
});

// تصدير المخطط بشكل صحيح
module.exports = orderSchema;
