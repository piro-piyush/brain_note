const mongoose = require('mongoose');

const docSchema = new mongoose.Schema(
    {
        uid: {
            type: String,
            required: true,
            unique: true,
        },
        title: {
            type: String,
            required: true,
            trim: true,
        },
        content: {
            type: Array,
            default: [],
        },
        createdAt: {
            required: true,
            type: Number,

        }
    }
);

module.exports = mongoose.model('Docuement', docSchema);
