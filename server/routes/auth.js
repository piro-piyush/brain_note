const express = require('express');
const router = express.Router();

const User = require('../models/user');
const ApiResponse = require('../utils/apiResponse');
const HttpStatus = require('../utils/httpStatus');
const auth = require('../middlewares/auth');

const jwt = require('jsonwebtoken');
const { OAuth2Client } = require('google-auth-library');
const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey';
const GOOGLE_CLIENT_ID = process.env.GOOGLE_CLIENT_ID;
const client = new OAuth2Client(GOOGLE_CLIENT_ID);


/* =====================================================
   SIGNUP
   POST /api/auth/signup
===================================================== */
router.post('/google', async (req, res) => {
  try {
    console.log('[Google Auth] Request body:', req.body);

    const { token, platform } = req.body; // token = idToken (mobile) or accessToken (web)

    if (!token || !platform) {
      console.warn('[Google Auth] Missing token or platform');
      return ApiResponse.error(
        res,
        'Token and platform are required',
        HttpStatus.BAD_REQUEST
      );
    }

    let payload;

    if (platform === 'web') {
      console.log('[Google Auth] Platform is Web, verifying accessToken...');
      // Verify accessToken via Google UserInfo endpoint
      const response = await fetch(
        `https://www.googleapis.com/oauth2/v3/userinfo?access_token=${token}`
      );

      if (!response.ok) {
        console.error('[Google Auth] Google token verification failed', response.status);
        return ApiResponse.error(
          res,
          'Invalid Google token',
          HttpStatus.UNAUTHORIZED
        );
      }

      payload = await response.json();
      console.log('[Google Auth] Google Web payload:', payload);

    } else {
      console.log('[Google Auth] Platform is Mobile, verifying idToken...');
      // Verify idToken using google-auth-library
      const ticket = await client.verifyIdToken({
        idToken: token,
        audience: GOOGLE_CLIENT_ID,
      });

      payload = ticket.getPayload();
      console.log('[Google Auth] Google Mobile payload:', payload);
    }

    const { name, email, picture } = payload;

    console.log(`[Google Auth] Searching user in DB: ${email}`);
    let user = await User.findOne({ email });

    if (!user) {
      console.log(`[Google Auth] User not found. Creating new user: ${email}`);
      user = await User.create({
        name,
        email,
        profileUrl: picture,
      });
      console.log('[Google Auth] User created:', user);
    } else {
      console.log('[Google Auth] Existing user found:', user);
    }

    console.log('[Google Auth] Generating JWT for user:', user.email);
    const jwtToken = jwt.sign(
      { id: user._id, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );
    console.log('[Google Auth] JWT generated:', jwtToken);

    return ApiResponse.success(
      res,
      { user, token: jwtToken },
      'Authenticated successfully',
      HttpStatus.OK
    );

  } catch (err) {
    console.error('[Google Auth] Error during authentication:', err);
    return ApiResponse.error(
      res,
      'Failed to verify Google token',
      HttpStatus.UNAUTHORIZED
    );
  }
});








module.exports = router;
