const mongoose = require('mongoose');

async function connectDatabase() {
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/cake_shop';

  mongoose.set('strictQuery', true);

  await mongoose.connect(uri);
  console.log('MongoDB connected:', mongoose.connection.name);
}

module.exports = { connectDatabase, mongoose };
