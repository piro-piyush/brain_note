require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const authRouter = require('./routes/auth');
const userRouter = require('./routes/user');

const app = express();

const PORT = process.env.PORT || 3001;


/* =====================================================
   MIDDLEWARES
===================================================== */

// JSON parser
app.use(express.json());

// CORS (safe config)
// app.use(
//     cors({
//         origin: ['http://localhost:3000'], // Flutter web
//         credentials: true,
//     })
// );
app.use(cors({
    origin: '*' // or restrict to your deployed frontend URL
}));

app.use((req, res, next) => {
    res.setHeader(
        'Cross-Origin-Opener-Policy',
        'same-origin-allow-popups'
    );
    res.setHeader(
        'Cross-Origin-Embedder-Policy',
        'unsafe-none'
    );
    next();
});

/* =====================================================
   ROUTES
===================================================== */

app.get('/', (req, res) => {
    res.send('🚀 Server running');
});

// all auth routes
app.use('/api/auth', authRouter);
app.use('/api/user', userRouter);

/* =====================================================
   DATABASE + SERVER START
===================================================== */

async function start() {
    try {
        await mongoose.connect(process.env.MONGO_URI);

        console.log('✅ MongoDB Connected');

        app.listen(PORT, '0.0.0.0', () => {
            console.log(`🚀 Server running → http://localhost:${PORT}`);
        });

    } catch (err) {
        console.error('❌ DB Error:', err);
        process.exit(1);
    }
}

start();
