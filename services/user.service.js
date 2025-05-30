// services/userService.js
const UserModel = require('../model/user.model');
const Joi = require('joi');  // مكتبة Joi للتحقق من البيانات

// مخطط التحقق من صحة البيانات باستخدام Joi
const userValidationSchema = Joi.object({
  name: Joi.string().min(3).max(50).required()
    .messages({
      'string.min': 'اسم المستخدم يجب أن يحتوي على 3 أحرف على الأقل',
      'string.max': 'اسم المستخدم يجب ألا يتجاوز 50 حرفاً',
      'any.required': 'اسم المستخدم مطلوب',
    }),
  phone: Joi.string().pattern(/^\d{10,15}$/).required()
    .messages({
      'string.pattern.base': 'رقم الهاتف يجب أن يحتوي على 10 إلى 15 رقمًا فقط',
      'any.required': 'رقم الهاتف مطلوب',
    }),
  address: Joi.string().required()
    .messages({
      'any.required': 'العنوان مطلوب',
    }),
  email: Joi.string().email().required()
    .messages({
      'string.email': 'البريد الإلكتروني غير صالح',
      'any.required': 'البريد الإلكتروني مطلوب',
    }),
  city: Joi.string().min(2).max(50).required()
    .messages({
      'string.min': 'المدينة يجب أن تحتوي على حرفين على الأقل',
      'string.max': 'المدينة يجب ألا تتجاوز 50 حرفاً',
      'any.required': 'المدينة مطلوبة',
    }),
});

class UserService {
  static async registerUser(data) {
    // التحقق من صحة البيانات
    const { error } = userValidationSchema.validate(data);
    if (error) {
      throw new Error(error.details[0].message);  // إذا كانت البيانات غير صالحة
    }

    try {
      // إنشاء مستخدم جديد
      const createUser = new UserModel(data); 
      return await createUser.save();  // حفظ المستخدم في قاعدة البيانات
    } catch (err) {
      throw new Error("Error while registering user: " + err.message);  // تحسين رسالة الخطأ
    }
  }
}

module.exports = UserService;