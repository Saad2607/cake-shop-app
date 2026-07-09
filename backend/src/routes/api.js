const express = require('express');
const authController = require('../controllers/authController');
const cakeController = require('../controllers/cakeController');
const cartController = require('../controllers/cartController');
const orderController = require('../controllers/orderController');
const adminController = require('../controllers/adminController');
const promoController = require('../controllers/promoController');
const { authMiddleware, adminMiddleware } = require('../middleware/auth');
const { registerRules, loginRules, forgotPasswordRules } = require('../utils/validators');

const router = express.Router();

// Auth
router.post('/auth/register', registerRules, authController.register);
router.post('/auth/login', loginRules, authController.login);
router.post('/auth/forgot-password', forgotPasswordRules, authController.forgotPassword);
router.get('/auth/profile', authMiddleware, authController.getProfile);
router.put('/auth/profile', authMiddleware, authController.updateProfile);

// Cakes (public read)
router.get('/cakes', cakeController.getAllCakes);
router.get('/cakes/:id', cakeController.getCakeById);

// Promos (public read — home banners)
router.get('/promos', promoController.getActivePromos);

// Cakes (admin)
router.post('/cakes', authMiddleware, adminMiddleware, cakeController.createCake);
router.put('/cakes/:id', authMiddleware, adminMiddleware, cakeController.updateCake);
router.delete('/cakes/:id', authMiddleware, adminMiddleware, cakeController.deleteCake);

// Cart
router.get('/cart', authMiddleware, cartController.getCart);
router.post('/cart', authMiddleware, cartController.addToCart);
router.put('/cart/:id', authMiddleware, cartController.updateCartItem);
router.delete('/cart/:id', authMiddleware, cartController.removeCartItem);

// Orders
router.post('/orders', authMiddleware, orderController.placeOrder);
router.get('/orders', authMiddleware, orderController.getOrders);
router.get('/orders/:id', authMiddleware, orderController.getOrderById);
router.patch('/orders/:id/cancel', authMiddleware, orderController.cancelOrder);
router.patch('/orders/:id/review', authMiddleware, orderController.submitReview);

// Admin
router.get('/admin/dashboard', authMiddleware, adminMiddleware, adminController.getDashboard);
router.get('/admin/customers', authMiddleware, adminMiddleware, adminController.getCustomers);
router.get('/admin/orders', authMiddleware, adminMiddleware, orderController.getAllOrders);
router.patch('/admin/orders/:id/status', authMiddleware, adminMiddleware, orderController.updateOrderStatus);
router.get('/admin/promos', authMiddleware, adminMiddleware, promoController.getAllPromosAdmin);
router.post('/admin/promos', authMiddleware, adminMiddleware, promoController.createPromo);
router.put('/admin/promos/:id', authMiddleware, adminMiddleware, promoController.updatePromo);
router.delete('/admin/promos/:id', authMiddleware, adminMiddleware, promoController.deletePromo);

module.exports = router;
