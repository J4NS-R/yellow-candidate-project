import { db } from '$lib/server/db';
import * as schema from '$lib/server/schema';
import { redirect } from '@sveltejs/kit';
import { and, eq } from 'drizzle-orm';


export async function load(ev) {
	if (!ev.cookies.get('registered')) {
		redirect(302, '/');
	} else if (!ev.cookies.get('phoneSaleId')) {
		redirect(302, '/register/device');
	}

	const customerId = parseInt(ev.cookies.get('customerId')!);
	const phoneSaleId = parseInt(ev.cookies.get('phoneSaleId')!);

	const saleData = await db.select().from(schema.phoneSalesTable).where(and(
		eq(schema.phoneSalesTable.customerId, customerId),
		eq(schema.phoneSalesTable.id, phoneSaleId)
	)).leftJoin(schema.paymentsTable, eq(schema.paymentsTable.saleId, schema.phoneSalesTable.id))
		.limit(1);

	const phoneSale = saleData[0].phone_sales!;
	const paymentStatus = saleData[0].payments?.paymentStatus;

	return {
		phoneSale: phoneSale,
		paymentStatus: paymentStatus || 'unstarted'
	};
}
