// This server wraps around the generated Svelte server
// Why? Svelte doesn't have websocket support, so we need express to wrap it.
import { handler } from '../build/handler.js';
import express from 'express';
import { handleStatusCallback, wsServer } from './websocket-manager.js';

const app = express();

app.use(express.json());
app.post('/webhook/payment-status', async (req, res) => {
	res.status(202).send();

	const body = req.body;
	// TODO tran ID
	handleStatusCallback(body.phoneSaleId, body.paymentStatus);
});

app.use(handler);

const httpServer = app.listen(3000, () => {
	console.log('Listening on port 3000');
});

httpServer.on('upgrade', (req, socket, head) => {
	wsServer.handleUpgrade(req, socket, head, socket => {
		wsServer.emit('connection', socket, req);
	});
});
