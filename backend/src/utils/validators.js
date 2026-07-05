const { body, validationResult } = require('express-validator');

const handleValidation = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: errors.array()[0].msg });
  }
  next();
};

const registerRules = [
  body('name').trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  body('email').isEmail().withMessage('Invalid email format'),
  body('phone').isLength({ min: 10 }).withMessage('Phone must be at least 10 digits'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
  handleValidation,
];

const loginRules = [
  body('email').isEmail().withMessage('Invalid email format'),
  body('password').notEmpty().withMessage('Password is required'),
  handleValidation,
];

module.exports = { registerRules, loginRules, handleValidation };
