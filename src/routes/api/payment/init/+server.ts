import { db } from '$lib/server/db';
import * as schema from '$lib/server/schema';
import type { InternalPaymentRequest, TelcoPaymentRequest, TelcoPaymentResponse } from '$lib/types';
import { and, eq } from 'drizzle-orm';
import { env } from '$env/dynamic/private';
import { Logger } from '$lib/logging';

const log = new Logger('/api/payment/init.server');

export async function POST(req) {
	// TODO auth
	const body: InternalPaymentRequest = await req.request.json();

	// TODO make a lib
	const saleCustomerData = await db.select().from(schema.phoneSalesTable)
		.where(
			and(
				eq(schema.phoneSalesTable.id, body.phoneSaleId),
				eq(schema.phoneSalesTable.customerId, body.customerId)
			)).leftJoin(schema.customersTable, eq(schema.phoneSalesTable.customerId, schema.customersTable.id))
		.limit(1);
	if (saleCustomerData.length === 0) {
		return new Response(JSON.stringify({ 'error': `Could not find phone sale with id ${body.phoneSaleId}` }), { status: 404 });
	}

	const phoneSale = saleCustomerData[0].phone_sales;
	const customer = saleCustomerData[0].customers!;

	// Make payment request to telco
	log.debug(`Send payment request to upstream with customer=${customer.id} and sale=${phoneSale.id}`);
	const telcoResp = await fetch(env.VITE_UPSTREAM_PAYMENT_URL, {
		method: 'POST',
		body: JSON.stringify({
			idOrPassport: customer.idOrPassportNo,
			amountMinor: phoneSale.amountMinor
		} as TelcoPaymentRequest),
		headers: {
			'Content-Type': 'application/json',
			'Accept': 'application/json'
		}
	});

	const telcoDetail: TelcoPaymentResponse = await telcoResp.json();
	if (Math.floor(telcoResp.status / 100) !== 2) {
		log.warn(`Received error from upstream: status ${telcoResp.status}`);
		return new Response(JSON.stringify({
			'error': 'Telco rejected transaction',
			'detail': telcoDetail
		}));
	}

	log.info(`Upstream payment initiated :${JSON.stringify(telcoDetail)}`);
	await db.insert(schema.paymentsTable).values({
		saleId: phoneSale.id,
		paymentStatus: telcoDetail.paymentStatus,
		paymentId: telcoDetail.paymentId
	}).onConflictDoUpdate({
		target: schema.paymentsTable.saleId,
		set: {
			paymentStatus: telcoDetail.paymentStatus,
			paymentId: telcoDetail.paymentId
		}
	});

	return new Response(JSON.stringify({
		'paymentStatus': telcoDetail.paymentStatus
	}), { status: telcoResp.status });
}
