const HttpStatus = require('./httpStatus');

class ApiResponse {
  static success(res, data, message = 'Success', code = HttpStatus.OK) {
    return res.status(code).json({
      success: true,
      message,
      data,
    });
  }

  static error(res, message = 'Error', code = HttpStatus.SERVER_ERROR) {
    return res.status(code).json({
      success: false,
      message,
    });
  }
}

module.exports = ApiResponse;
