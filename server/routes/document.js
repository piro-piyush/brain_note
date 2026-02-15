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

/* =====================================================
   GET MY DOCUMENTS
   GET /api/docs/me
===================================================== */
router.get('/me', auth, async (req, res) => {
  try {
    const documents = await Document.find({
      uid: req.userId
    }).sort({ createdAt: -1 }).lean();

    console.log(
      `[DOC_FETCH] user=${req.userId} count=${documents.length}`
    );

    return ApiResponse.success(
      res,
      documents,
      'Documents fetched successfully',
      HttpStatus.OK
    );

  } catch (error) {
    console.error(
      `[DOC_FETCH_ERROR] user=${req.userId} message=${error.message}`
    );

    return ApiResponse.error(
      res,
      'Failed to fetch documents',
      HttpStatus.INTERNAL_SERVER_ERROR
    );
  }
});


module.exports = router;
