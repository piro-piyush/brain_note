const express = require('express');
const router = express.Router();

const Document = require('../models/document');
const ApiResponse = require('../utils/apiResponse');
const HttpStatus = require('../utils/httpStatus');
const auth = require('../middlewares/auth');

/* =====================================================
   CREATE DOCUMENT
   POST /api/docs/create
===================================================== */
router.post('/', auth, async (req, res) => {
  try {
    const { createdAt } = req.body;
    const newDocument = new Document({
      uid: req.user,
      title: 'Untitled Document',
      createdAt,
    });

    const savedDocument = await newDocument.save();

    return ApiResponse.success(
      res,
      savedDocument,
      'Document created successfully',
      HttpStatus.CREATED
    );

  } catch (error) {
    console.error('[Create Document Error]:', error);

    return ApiResponse.error(
      res,
      'Failed to create document',
      HttpStatus.INTERNAL_SERVER_ERROR
    );
  }
});

module.exports = router;
