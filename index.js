const express = require('express');
const mongoose = require('mongoose');
const http = require('http');
const https = require('https');
const fs = require('fs');
const WebSocket = require('ws');
const cors = require('cors');

const app = express();
const port = 8080;

app.use(cors());
app.use(express.json());

const privateKey = fs.readFileSync('server.key', 'utf8');
const certificate = fs.readFileSync('server.cert', 'utf8');
const credentials = { key: privateKey, cert: certificate };

const httpServer = http.createServer(app);
const httpsServer = https.createServer(credentials, app);

const wss = new WebSocket.Server({ server: httpsServer });

mongoose.connect('mongodb://localhost/reo', {
  useNewUrlParser: true,
  useUnifiedTopology: true
}).then(() => {
  console.log('Connected to MongoDB');
}).catch(err => {
  console.error('MongoDB connection error:', err);
});

const userSchema = new mongoose.Schema({
  userId: String,
  username: String,
  skins: [String],
  vbucks: Number,
  progress: Object
});
const User = mongoose.model('User', userSchema);

wss.on('connection', ws => {
  console.log('New WebSocket connection');
  ws.on('message', message => {
    console.log('Received:', message);
    ws.send('Reo server: Message received');
  });
});

app.get('/fortnite/api/game/v2/profile/:userId', async (req, res) => {
  const { userId } = req.params;
  try {
    const user = await User.findOne({ userId });
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json({
      profileId: userId,
      username: user.username,
      skins: user.skins || ['og_default'],
      vbucks: user.vbucks || 0,
      progress: user.progress || { level: 1 }
    });
  } catch (err) {
    res.status(500).json({ error: 'Server error' });
  }
});

app.post('/fortnite/api/matchmaking/join', (req, res) => {
  res.json({
    sessionId: `session_${Date.now()}`,
    status: 'Joined',
    gameMode: 'BattleRoyale'
  });
});

app.get('/fortnite/api/storefront/v2/catalog', (req, res) => {
  res.json({
    storefront: {
      items: [
        { itemId: 'renegade_raider', price: 1200 },
        { itemId: 'aerial_assault_trooper', price: 800 }
      ]
    }
  });
});

httpServer.listen(port, () => {
  console.log(`Reo HTTP server running on http://localhost:${port}`);
});
httpsServer.listen(8443, () => {
  console.log('Reo HTTPS server running on https://localhost:8443');
});