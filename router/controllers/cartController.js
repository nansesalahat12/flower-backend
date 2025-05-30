const cartService = require('../services/cartService');

exports.getCart = async (req, res) => {
  const cart = await cartService.getCartByUserId(req.params.userId);
  res.json(cart);
};

exports.addToCart = async (req, res) => {
  const { userId, productId, quantity } = req.body;
  const cart = await cartService.addToCart(userId, productId, quantity);
  res.json(cart);
};

exports.removeFromCart = async (req, res) => {
  const { userId, productId } = req.body;
  const cart = await cartService.removeFromCart(userId, productId);
  res.json(cart);
};

exports.clearCart = async (req, res) => {
  const { userId } = req.params;
  const result = await cartService.clearCart(userId);
  res.json({ message: "Cart cleared", result });
};

exports.removeItemFromCart = async (req, res) => {
  const { itemId } = req.params;
  const result = await cartService.removeItemById(itemId);

  if (!result) {
    return res.status(404).json({ error: 'العنصر غير موجود' });
  }

  res.json({ message: 'تم حذف العنصر من السلة', result });
};
