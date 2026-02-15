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
    const { createdAt } = req.body;

    const newDocument = new Document({
      uid: req.userId,
      title: 'Untitled Document',
      createdAt: createdAt || new Date(), // fallback
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
   UPDATE TITLE
   POST /api/docs/title
===================================================== */
router.post('/title', auth, async (req, res) => {
  try {
    const { id, title } = req.body;

    if (!id || !title) {
      return ApiResponse.error(
        res,
        'Document id and title are required',
        HttpStatus.BAD_REQUEST
      );
    }

    const document = await Document.findByIdAndUpdate(
      id,
      { title },
      { new: true } // return updated document
    );

    if (!document) {
      return ApiResponse.error(
        res,
        'Document not found',
        HttpStatus.NOT_FOUND
      );
    }

    console.log(
      `[DOC_UPDATED] user=${req.userId} docId=${document._id}`
    );

    return ApiResponse.success(
      res,
      document,
      'Document updated successfully',
      HttpStatus.OK
    );

  } catch (error) {
    console.error(
      `[DOC_UPDATE_ERROR] user=${req.userId} message=${error.message}`
    );

    return ApiResponse.error(
      res,
      'Failed to update document',
      HttpStatus.INTERNAL_SERVER_ERROR
    );
  }
});


/* GET MY DOCUMENTS */
router.get('/me', auth, async (req, res) => {
  try {
    const documents = await Document.find({
      uid: req.userId
    })
      .sort({ createdAt: -1 })
      .lean();

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


/* GET SINGLE DOCUMENT */
router.get('/:id', auth, async (req, res) => {
  try {
    const document = await Document.findById(req.params.id);

    if (!document) {
      return ApiResponse.error(
        res,
        'Document not found',
        HttpStatus.NOT_FOUND
      );
    }

    return ApiResponse.success(
      res,
      document,
      'Document fetched successfully',
      HttpStatus.OK
    );
  } catch (error) {
    console.error(
      `[DOC_FETCH_ERROR] user=${req.userId} message=${error.message}`
    );

    return ApiResponse.error(
      res,
      'Failed to fetch document',
      HttpStatus.INTERNAL_SERVER_ERROR
    );
  }
});



module.exports = router;
