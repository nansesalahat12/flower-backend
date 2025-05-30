//flowerrouter.js
const express = require("express");
const router = express.Router();
const Joi = require("joi");
const { v4: uuidv4 } = require("uuid"); // إضافة UUID لتوليد معرف فريد

// بيانات الورود
const flowers = [
  { id: uuidv4(), name: "Rose", price: 20 },
  { id: uuidv4(), name: "Tulip", price: 15 }
];

// التحقق من البيانات المدخلة باستخدام Joi
const validateFlower = (flower) => {
  const schema = Joi.object({
    name: Joi.string().min(3).required(),
    price: Joi.number().min(1).required(),
    // إضافة خصائص أخرى إذا لزم الأمر
  });
  return schema.validate(flower);
};

// الحصول على جميع الورود
router.get("/", (req, res) => {
  res.status(200).json(flowers);
});

// الحصول على وردة معينة بناءً على ID
router.get("/:id", (req, res) => {
  const flower = flowers.find(f => f.id === req.params.id);
  if (!flower) return res.status(404).json({ message: "Flower not found", id: req.params.id });
  res.status(200).json(flower);
});

// إضافة وردة جديدة
router.post("/", (req, res) => {
  const { error } = validateFlower(req.body);
  if (error) return res.status(400).send(error.details[0].message);

  const flower = {
    id: uuidv4(), // توليد id فريد باستخدام UUID
    name: req.body.name,
    price: req.body.price
  };
  flowers.push(flower);
  res.status(201).json(flower);
});

module.exports = router;