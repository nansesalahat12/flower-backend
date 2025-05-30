// routes/bouquet.router.js
const express = require('express');
const router = express.Router();
const { addBouquet, getBouquetsByUser, deleteBouquet } = require('../controllers/bouquet.controller');

// إضافة باقة جديدة
router.post('/', addBouquet);

// جلب الباقات الخاصة بمستخدم
router.get('/:userId', getBouquetsByUser);

// حذف باقة
router.delete('/:id', deleteBouquet);

module.exports = router;