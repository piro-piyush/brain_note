require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');


const app = express();
app.use(express.json());
app.use(authRouter);

const PORT = process.env.PORT || 3001;

/* ---------- Middlewares ---------- */
app.use(express.json());

/* ---------- Test Route ---------- */
app.get('/', (req, res) => {
    res.send('Server running 🚀');
});

/* ---------- Start App ---------- */
async function start() {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('✅ MongoDB Connected');

        app.listen(PORT, () =>
            console.log(`🚀 Server running on http://localhost:${PORT}`)
        );

    } catch (err) {
        console.error('❌ DB Error:', err.message);
    }
}

start();
