import { WebSocketServer } from 'ws';

/** @type {Map<number, (string)=>void>} */
const connectedClients = new Map();

function newCallback(socket) {
	return (payload) => {
		console.debug(`ws-proxy: Sending payload downstream: ${payload}`);
		socket.send(payload);
	};
}

export const wsServer = new WebSocketServer({ noServer: true });

wsServer.on('connection', socket => {
	console.log('ws-proxy: ws client connected.');
	socket.on('message', message => {
		console.log('ws-proxy: Received message: ' + message);
		/** @type {{phoneSaleId: number}} */
		const parsed = JSON.parse(message);

		connectedClients.set(parsed.phoneSaleId, newCallback(socket, parsed.phoneSaleId));
		console.log(`ws-proxy: Connection registered with id=${parsed.phoneSaleId}`);
	});
});

export function sendWebsocketMessage(clientId, body) {
	if (!connectedClients.has(clientId)) {
		console.warn(`ws-proxy: Cannot execute status callback because clientId ${clientId} is not registered.`);
		return;
	}

	if (typeof body === 'object') {
		body = JSON.stringify(body);
	}

	connectedClients.get(clientId)(body);
}
