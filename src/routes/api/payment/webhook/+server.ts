// TODO receive webhook from upstream
// Store status in DB
// And send message to websocket

import type { TelcoPaymentResponse } from '$lib/types';
import { db } from '$lib/server/db';
import { eq } from 'drizzle-orm';
import { paymentsTable } from '$lib/server/schema';
import { Logger } from '$lib/logging';

const log = new Logger('/api/payment/webhook.server');

export async function POST(req) {
	const body: TelcoPaymentResponse = await req.request.json();

	let paymentInfo = await db.query.paymentsTable.findFirst({ where: eq(paymentsTable.paymentId, body.paymentId) });
	if (!paymentInfo) {
		return new Response(JSON.stringify({ error: `Payment with ID ${body.paymentId} not found` }), { status: 404 });
	}

	// Update DB with new payment status
	log.info(`Updating payment ${body.paymentId} to status ${body.paymentStatus}`);
	paymentInfo = (await db.update(paymentsTable).set({
		paymentStatus: body.paymentStatus
	}).where(eq(paymentsTable.paymentId, body.paymentId))
		.returning())[0];

	// Send webhook info
	log.debug(`Calling websocket client ${paymentInfo.saleId}`);
	await fetch('http://localhost:3000/websocket/' + paymentInfo.saleId, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json'
		},
		body: JSON.stringify(paymentInfo)
	});

	return new Response('', { status: 200 });
}
