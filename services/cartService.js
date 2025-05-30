const Cart = require('../model/cart');

const getCartByUserId = async (userId) => {
  return await Cart.findOne({ userId }).populate('items.productId');
};

const addToCart = async (userId, productId, quantity) => {
  let cart = await Cart.findOne({ userId });
  if (!cart) {
    cart = new Cart({ userId, items: [] });
  }

  const existingItem = cart.items.find(item => item.productId.toString() === productId);
  if (existingItem) {
    existingItem.quantity += quantity;
  } else {
    cart.items.push({ productId, quantity });
  }

  return await cart.save();
};

const removeFromCart = async (userId, productId) => {
  const cart = await Cart.findOne({ userId });
  if (!cart) return null;
  cart.items = cart.items.filter(item => item.productId.toString() !== productId);
  return await cart.save();
};

const clearCart = async (userId) => {
  return await Cart.findOneAndDelete({ userId });
};

module.exports = {
  getCartByUserId,
  addToCart,
  removeFromCart,
  clearCart
};
