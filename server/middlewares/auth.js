const jwt = require('jsonwebtoken');
const ApiResponse = require('../utils/apiResponse');
const HttpStatus = require('../utils/httpStatus');

const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey';

const auth = (req, res, next) => {
  try {
    console.log('[Auth Middleware] Incoming request headers:', req.headers);

    /* ---------- get token ---------- */
    const authHeader = req.header('Authorization');
    if (!authHeader) {
      console.warn('[Auth Middleware] No Authorization header provided');
      return ApiResponse.error(
        res,
        'No token provided',
        HttpStatus.UNAUTHORIZED
      );
    }

    /* ---------- Bearer token ---------- */
    const token = authHeader.replace('Bearer ', '');
    console.log('[Auth Middleware] Extracted token:', token);

    /* ---------- verify ---------- */
    let verified;
    try {
      verified = jwt.verify(token, JWT_SECRET);
      console.log('[Auth Middleware] Token verified successfully:', verified);
    } catch (verifyErr) {
      console.error('[Auth Middleware] Token verification failed:', verifyErr);
      return ApiResponse.error(
        res,
        'Invalid token',
        HttpStatus.UNAUTHORIZED
      );
    }

    /* ---------- attach user ---------- */
    req.userId = verified.id;
    req.token = token;
    console.log(`[Auth Middleware] Attached userId: ${req.userId}`);

    next();

  } catch (err) {
    console.error('[Auth Middleware] Unexpected error:', err);
    return ApiResponse.error(
      res,
      'Unauthorized',
      HttpStatus.UNAUTHORIZED
    );
  }
};

module.exports = auth;
