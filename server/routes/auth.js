const express = require('express');
const router = express.Router();

const User = require('../models/user');
const ApiResponse = require('../utils/apiResponse');
const HttpStatus = require('../utils/httpStatus');
const auth = require('../middlewares/auth');

const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey';


/* =====================================================
   SIGNUP
   POST /api/auth/signup
===================================================== */
router.post('/signup', async (req, res) => {
    try {
        const { name, email, profileUrl } = req.body;

        /* ---------- validation ---------- */
        if (!name || !email || !profileUrl) {
            return ApiResponse.error(
                res,
                'All fields are required',
                HttpStatus.BAD_REQUEST
            );
        }

        /* ---------- duplicate check ---------- */
        const existingUser = await User.findOne({ email });

        if (existingUser) {
            return ApiResponse.error(
                res,
                'Email already registered',
                HttpStatus.CONFLICT
            );
        }

        /* ---------- create user ---------- */
        const user = await User.create({ name, email, profileUrl });

        /* ---------- generate token ---------- */
        const token = jwt.sign(
            {
                id: user._id,
                email: user.email,
            },
            JWT_SECRET,
            { expiresIn: '7d' }
        );


        return ApiResponse.success(
            res,
            { user, token },
            'User created successfully',
            HttpStatus.CREATED
        );

    } catch (err) {
        console.error(err);

        return ApiResponse.error(
            res,
            'Server error',
            HttpStatus.SERVER_ERROR
        );
    }
});


/* =====================================================
   GET CURRENT USER
   GET /api/auth/me
===================================================== */
router.get('/', auth, async (req, res) => {
    try {
        const user = await User.findById(req.userId).select('-__v');

        return ApiResponse.success(
            res,
            { user, token: req.token },
            'User fetched successfully',
            HttpStatus.OK
        );

    } catch (err) {
        console.error(err);

        return ApiResponse.error(
            res,
            'Server error',
            HttpStatus.SERVER_ERROR
        );
    }
});


module.exports = router;
