const express = require('express');
const router = express.Router();

const Document = require('../models/document');
const ApiResponse = require('../utils/apiResponse');
const HttpStatus = require('../utils/httpStatus');
const auth = require('../middlewares/auth');


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


/* =====================================================
   GET SINGLE DOCUMENT
   GET /api/docs/:id
===================================================== */
router.get('/:id', auth, async (req, res) => {
  try {
    const document = await Document.findById(req.params.id).lean();

    if (!document) {
      return ApiResponse.error(
        res,
        'Document not found',
        HttpStatus.NOT_FOUND
      );
    }

    console.log(
      `[DOC_SINGLE_FETCH] user=${req.userId} docId=${document._id}`
    );

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
