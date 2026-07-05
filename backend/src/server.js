require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectDatabase } = require('./config/database');
const apiRoutes = require('./routes/api');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'Cake Shop API', database: 'MongoDB' });
});

app.use('/api', apiRoutes);

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

async function start() {
  try {
    await connectDatabase();
    app.listen(PORT, '0.0.0.0', () => {
      console.log(`Cake Shop API running on http://localhost:${PORT}`);
      console.log(`Phone access: http://10.227.28.97:${PORT}/health`);
      console.log(`API base:     http://10.227.28.97:${PORT}/api`);
    });
  } catch (error) {
    console.error('Failed to start server:', error.message);
    process.exit(1);
  }
}

start();
