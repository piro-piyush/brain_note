const express = require('express');
const router = express.Router();

const User = require('../models/user');
const ApiResponse = require('../utils/apiResponse');
const HttpStatus = require('../utils/httpStatus');
const auth = require('../middlewares/auth');


/* =====================================================
   GET CURRENT USER
   GET /api/auth/me
===================================================== */
router.get('/', auth, async (req, res) => {
    try {
        console.log('[User Route] Request received');
        console.log('[User Route] Authenticated userId:', req.userId);
        console.log('[User Route] Token from auth middleware:', req.token);

        // Fetch user from DB
        const user = await User.findById(req.userId).select('-__v');

        if (!user) {
            console.warn(`[User Route] User not found for ID: ${req.userId}`);
            return ApiResponse.error(
                res,
                'User not found',
                HttpStatus.NOT_FOUND
            );
        }

        console.log('[User Route] User fetched from DB:', user);

        return ApiResponse.success(
            res,
            { user, token: req.token },
            'User fetched successfully',
            HttpStatus.OK
        );

    } catch (err) {
        console.error('[User Route] Server error:', err);

        return ApiResponse.error(
            res,
            'Server error',
            HttpStatus.SERVER_ERROR
        );
    }
});
module.exports = router;
