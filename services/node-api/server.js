'use strict'

const express = require('express');
const PORT = process.env.PORT || 3000;
const BASE_PATH = process.env.BASE_PATH || '/';

const app = express();

app.get(`${BASE_PATH}/`, (req, res) => {
    res.send('Hello');
});

app.get(`${BASE_PATH}/healthz`, (req, res) => {
    res.send({
        "status": "up"
    });
});

// Force an NPE
app.get(`${BASE_PATH}/icanhaznpe`, (req, res) => {
    const obj = null;
    res.send(obj.get());
});

app.listen(PORT, () => {
    console.log(`Listening on port ${PORT}`);
});

process.on('SIGINT', () => {
    console.log('Caught interrupt signal, exiting.');
    process.exit();
});
