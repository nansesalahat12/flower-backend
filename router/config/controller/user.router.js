const express = require('express');
const router = express.Router();
const Joi = require('joi');
const { registerUser, loginUser } = require('../../controllers/usercontroller'); // تأكد من المسار الصحيح

// مخطط التحقق من البيانات لتسجيل المستخدم
const userValidationSchema = Joi.object({
  name: Joi.string().min(3).max(50).required().messages({
    'string.min': 'اسم المستخدم يجب أن يحتوي على 3 أحرف على الأقل',
    'string.max': 'اسم المستخدم يجب ألا يتجاوز 50 حرفاً',
    'any.required': 'اسم المستخدم مطلوب',
  }),
  phone: Joi.string().pattern(/^\d{10,15}$/).required().messages({
    'string.pattern.base': 'رقم الهاتف يجب أن يحتوي على 10 إلى 15 رقمًا فقط',
    'any.required': 'رقم الهاتف مطلوب',
  }),
  address: Joi.string().required().messages({
    'any.required': 'العنوان مطلوب',
  }),
  email: Joi.string().email().required().messages({
    'string.email': 'البريد الإلكتروني غير صالح',
    'any.required': 'البريد الإلكتروني مطلوب',
  }),
  city: Joi.string().min(2).max(50).required().messages({
    'string.min': 'المدينة يجب أن تحتوي على حرفين على الأقل',
    'string.max': 'المدينة يجب ألا تتجاوز 50 حرفاً',
    'any.required': 'المدينة مطلوبة',
  }),
  password: Joi.string()
    .pattern(/^(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$/)
    .required()
    .messages({
      'string.pattern.base': 'كلمة المرور يجب أن تحتوي على 8 خانات على الأقل، حرف كبير، رقم، ورمز',
      'any.required': 'كلمة المرور مطلوبة',
    }),
});

// مخطط التحقق من البيانات لتسجيل الدخول
const loginValidationSchema = Joi.object({
  email: Joi.string().email().required().messages({
    'string.email': 'البريد الإلكتروني غير صالح',
    'any.required': 'البريد الإلكتروني مطلوب',
  }),
  password: Joi.string().required().messages({
    'any.required': 'كلمة المرور مطلوبة',
  }),
});

// Middleware للتحقق من بيانات التسجيل
const validateUser = (req, res, next) => {
  const { error } = userValidationSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  next();
};

// Middleware للتحقق من بيانات تسجيل الدخول
const validateLogin = (req, res, next) => {
  const { error } = loginValidationSchema.validate(req.body);
  if (error) {
    return res.status(400).json({ error: error.details[0].message });
  }
  next();
};

// مسار تسجيل المستخدم
router.post('/register', validateUser, registerUser);

// مسار تسجيل الدخول
router.post('/signin', validateLogin, loginUser);

module.exports = router;