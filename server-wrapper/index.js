// This server wraps around the generated Svelte server
// Why? Svelte doesn't have websocket support, so we need express to wrap it.
import { handler } from '../build/handler.js';
import express from 'express';
import cors from 'cors';
import { sendWebsocketMessage, wsServer } from './websocket-manager.js';

const app = express();

// This endpoint allows the svelte server to send websocket messages to the client
app.use(express.json());
if (process.env.NODE_ENV !== 'production') {
	app.use(cors());
}
app.post('/websocket/:id', async (req, res) => {
	if (req.headers['x-api-key'] !== process.env.VITE_API_KEY) {
		console.log('Rejecting websocket request because its API key is wrong.');
		res.status(403).send('Bad API key!');
		return;
	}
	res.status(202).send();
	sendWebsocketMessage(parseInt(req.params.id), req.body);
});

// Setup svelte server
if (process.env.NODE_ENV === 'production') {
	app.use(handler);
}
const httpServer = app.listen(3000, () => {
	console.log('Listening on port 3000');
});

// Handle websocket requests
httpServer.on('upgrade', (req, socket, head) => {
	wsServer.handleUpgrade(req, socket, head, socket => {
		wsServer.emit('connection', socket, req);
	});
});
