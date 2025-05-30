const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  try {
    const token = req.headers.authorization.split(' ')[1];
    if (!token) {
      return res.status(403).json({ message: 'توكن مفقود' });
    }

    const decodedToken = jwt.verify(token, 'your_jwt_secret');
    req.userData = decodedToken;

    if (req.userData.role !== 'admin') {
      return res.status(403).json({ message: 'غير مصرح لك بالوصول' });
    }

    next();
  } catch (error) {
    return res.status(401).json({ message: 'توكن غير صالح' });
  }
};