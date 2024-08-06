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
	const phoneSale = await db.query.phoneSalesTable.findFirst({
		where: and(
			eq(schema.phoneSalesTable.customerId, customerId),
			eq(schema.phoneSalesTable.id, phoneSaleId)
		)
	});

	return {
		phoneSale: phoneSale!
	};
}
