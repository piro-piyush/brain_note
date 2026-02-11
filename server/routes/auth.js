const express = require('express');
const router = express.Router();

const User = require('../models/user');

/* ---------------- SIGNUP ---------------- */
router.post('/api/auth/signup', async (req, res) => {
  try {
    const { name, email, profileUrl } = req.body;

    // basic validation
    if (!name || !email || !profileUrl) {
      return res.status(400).json({ message: 'All fields are required' });
    }

    // check existing user
    const existingUser = await User.findOne({ email });

    if (existingUser) {
      return res.status(409).json({ message: 'Email already registered' });
    }

    // create user
    const user = await User.create({ name, email, profileUrl });

    res.status(201).json({
      message: 'User created successfully',
      user,
    });

  } catch (err) {
    console.error(err);
    res.status(500).json({ message: 'Server error' });
  }
});

module.exports = router;
