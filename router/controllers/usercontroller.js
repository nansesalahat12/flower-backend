const bcrypt = require('bcrypt');
const { User } = require('../../model/usermodel.js'); // تأكد من أن المسار صحيح

// دالة تسجيل المستخدم
const registerUser = async (req, res, next) => {
  try {
    const { name, phone, address, email, city, password } = req.body;

    // تحقق إذا كان المستخدم موجودًا بالفعل باستخدام البريد الإلكتروني أو رقم الهاتف
    const existingUser = await User.findOne({ $or: [{ email }, { phone }] });
    if (existingUser) {
      return res.status(400).json({
        status: false,
        message: 'البريد الإلكتروني أو رقم الهاتف موجود بالفعل.',
      });
    }

    // تشفير كلمة المرور
    const hashedPassword = await bcrypt.hash(password, 10);

    // تعيين الدور بناءً على البريد الإلكتروني
    const role = email === 'admin@flowerapp.com' ? 'admin' : 'user';

    // إنشاء مستخدم جديد
    const newUser = new User({
      name,
      phone,
      address,
      email,
      city,
      password: hashedPassword,
      role,
    });

    // حفظ المستخدم في قاعدة البيانات
    const savedUser = await newUser.save();

    res.status(201).json({
      status: true,
      message: 'تم تسجيل المستخدم بنجاح',
      data: savedUser,
    });
  } catch (error) {
    next(error); // تمرير الخطأ إلى معالج الأخطاء
  }
};

// دالة تسجيل الدخول
const loginUser = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    // تحقق من أن البريد الإلكتروني وكلمة المرور موجودين
    if (!email || !password) {
      return res.status(400).json({
        status: false,
        message: 'يرجى إدخال البريد الإلكتروني وكلمة المرور',
      });
    }

    // البحث عن المستخدم بواسطة البريد الإلكتروني
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({
        status: false,
        message: 'البريد الإلكتروني غير مسجل.',
      });
    }

    // التحقق من أن كلمة المرور موجودة في قاعدة البيانات
    if (!user.password) {
      return res.status(400).json({
        status: false,
        message: 'كلمة المرور غير موجودة.',
      });
    }

    // التحقق من صحة كلمة المرور
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({
        status: false,
        message: 'كلمة المرور غير صحيحة.',
      });
    }

    // تسجيل الدخول ناجح
    res.status(200).json({
      status: true,
      message: 'تم تسجيل الدخول بنجاح',
      data: user,
    });
  } catch (error) {
    next(error); // تمرير الخطأ إلى معالج الأخطاء
  }
};

module.exports = { registerUser, loginUser };