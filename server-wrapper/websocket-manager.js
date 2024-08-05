import { WebSocketServer } from 'ws';

/** @type {Map<number, {statusCallback: (string)=>void}>} */
const state = new Map();

function newCallback(socket, phoneSaleId) {
	return (paymentStatus) => {
		// TODO send msg to svelte to update DB

		let payload = JSON.stringify({ paymentStatus });
		console.debug(`Sending payload downstream: ${payload}`);
		socket.send(payload);
	};
}

export const wsServer = new WebSocketServer({ noServer: true });

wsServer.on('connection', socket => {
	console.log('ws client connected.');
	socket.on('message', message => {
		console.log('Received message: ' + message);
		/** @type {{phoneSaleId: number}} */
		const parsed = JSON.parse(message);

		state.set(parsed.phoneSaleId, {
			statusCallback: newCallback(socket, parsed.phoneSaleId)
		});
		console.log(`Callback registered with id=${parsed.phoneSaleId}`);
	});
});

export function handleStatusCallback(phoneSaleId, paymentStatus) {
	if (!state.has(phoneSaleId)) {
		console.warn(`Cannot execute status callback because phoneSaleId ${phoneSaleId} is not registered.`);
		return;
	}

	state.get(phoneSaleId).statusCallback(paymentStatus);
}
