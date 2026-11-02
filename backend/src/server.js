require('dotenv').config();
const express = require('express');
const cors = require('cors');
const os = require('os');
const { connectDatabase } = require('./config/database');
const apiRoutes = require('./routes/api');
const { productSharePage } = require('./controllers/shareController');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'Cake Shop API', database: 'MongoDB' });
});

// Public product share page (Amazon-style link preview)
app.get('/p/:id', productSharePage);

app.use('/api', apiRoutes);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

function getLocalIp() {
  const interfaces = os.networkInterfaces();
  for (const name of Object.keys(interfaces)) {
    for (const iface of interfaces[name]) {
      if (iface.family === 'IPv4' && !iface.internal) {
        return iface.address;
      }
    }
  }
  return 'localhost';
}

async function start() {
  try {
    await connectDatabase();
    app.listen(PORT, '0.0.0.0', () => {
      const localIp = getLocalIp();
      console.log(`\n==============================================`);
      console.log(` Cake Shop API Server Running`);
      console.log(` Local:        http://localhost:${PORT}`);
      console.log(` Phone / LAN:  http://${localIp}:${PORT}/api`);
      console.log(` Health Check: http://${localIp}:${PORT}/health`);
      console.log(`==============================================\n`);
    });
  } catch (error) {
    console.error('Failed to start server:', error.message);
    process.exit(1);
  }
}

start();
