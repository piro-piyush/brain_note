const jwt = require('jsonwebtoken');

const ApiResponse = require('../utils/apiResponse');
const HttpStatus = require('../utils/httpStatus');

const JWT_SECRET = process.env.JWT_SECRET || 'supersecretkey';

const auth = (req, res, next) => {
  try {
    /* ---------- get token ---------- */
    const authHeader = req.header('Authorization');

    if (!authHeader) {
      return ApiResponse.error(
        res,
        'No token provided',
        HttpStatus.UNAUTHORIZED
      );
    }

    /* ---------- Bearer token ---------- */
    const token = authHeader.replace('Bearer ', '');

    /* ---------- verify ---------- */
    const verified = jwt.verify(token, JWT_SECRET);

    /* ---------- attach user ---------- */
    req.userId = verified.id;
    req.token = token;

    next();

  } catch (err) {
    console.error(err);

    return ApiResponse.error(
      res,
      'Unauthorized',
      HttpStatus.UNAUTHORIZED
    );
  }
};

module.exports = auth;
