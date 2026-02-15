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
router.post('/create', auth, async (req, res) => {
  try {
    console.log('[Create Doc] Request body:', req.body);

    const { createdAt } = req.body;

    const newDocument = new Document({
      uid: req.userId,
      title: 'Untitled Document',
      createdAt,
    });

    const savedDocument = await newDocument.save();

    console.log(
      `[DOC_CREATED] user=${req.userId} docId=${savedDocument._id}`
    );

    return ApiResponse.success(
      res,
      savedDocument,
      'Document created successfully',
      HttpStatus.CREATED
    );

  } catch (error) {
    console.error(
      `[DOC_CREATE_ERROR] user=${req.userId} message=${error.message}`
    );

    return ApiResponse.error(
      res,
      'Failed to create document',
      HttpStatus.INTERNAL_SERVER_ERROR
    );
  }
});


module.exports = router;
