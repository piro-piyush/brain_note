require('dotenv').config();

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const http = require('http');
const { Server } = require('socket.io');

const authRouter = require('./routes/auth');
const userRouter = require('./routes/user');
const documentRouter = require('./routes/document');

const app = express();
var server = http.createServer(app);
var io = require("socket.io")(server);
const PORT = process.env.PORT || 3001;


/* =====================================================
   MIDDLEWARES
===================================================== */

app.use(express.json());

app.use(cors({
    origin: '*',
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
   REQUEST LOGGER
===================================================== */

app.use((req, res, next) => {
    const start = Date.now();

    res.on('finish', () => {
        const duration = Date.now() - start;
        console.log(
            `[${req.method}] ${req.originalUrl} ${res.statusCode} - ${duration}ms`
        );
    });

    next();
});


/* =====================================================
   ROUTES
===================================================== */

app.get('/', (_, res) => {
    res.send('🚀 Server running');
});

app.use('/api/auth', authRouter);
app.use('/api/user', userRouter);
app.use('/api/docs', documentRouter);


/* =====================================================
   SOCKET.IO
===================================================== */

io.on('connection', (socket) => {
    console.log(`🔌 Socket connected: ${socket.id}`);


    socket.on("join", (documentId) => {
        socket.join(documentId);
    });

    socket.on("typing", (data) => {
        socket.broadcast.to(data.room).emit("changes", data);
    });

    socket.on("save", (data) => {
        saveData(data);
    });
});
const saveData = async (data) => {
    let document = await Document.findById(data.room);
    document.content = data.delta;
    document = await document.save();
};

/* =====================================================
   DATABASE + SERVER START
===================================================== */

async function start() {
    try {
        await mongoose.connect(process.env.MONGO_URI);

        console.log('✅ MongoDB Connected');

        server.listen(PORT, '0.0.0.0', () => {
            console.log(`🚀 Server running → http://localhost:${PORT}`);
        });

    } catch (err) {
        console.error('❌ DB Error:', err);
        process.exit(1);
    }
}

start();
