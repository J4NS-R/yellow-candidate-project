import { redirect } from '@sveltejs/kit';
import { db } from '$lib/server/db';
import * as schema from '$lib/server/schema';
import { Logger } from '$lib/logging';
import { and, eq } from 'drizzle-orm';

const log = new Logger('/register/device.server');

export async function load(ev) {
	if (!ev.cookies.get('registered')) {
		redirect(302, '/');
	}

	const customerId = parseInt(ev.cookies.get('customerId')!);
	let phoneSale = undefined;

	if (ev.cookies.get('phoneSaleId')) {
		phoneSale = await db.query.phoneSalesTable.findFirst({
			where: and(
				eq(schema.phoneSalesTable.customerId, customerId),
				eq(schema.phoneSalesTable.id, parseInt(ev.cookies.get('phoneSaleId')!))
			)
		});
	}

	return {
		registered: phoneSale !== undefined,
		customerId,
		phoneSale
	};
}

export const actions = {
	default: async (ev) => {
		const formData = await ev.request.formData();

		log.debug('Inserting new phone sale');
		const phoneSale = (await db.insert(schema.phoneSalesTable).values({
			customerId: parseInt(formData.get('customerid')!.toString()),
			amountMinor: Math.round(parseInt(formData.get('amountzar')!.toString()) * 100),
			makeAndModel: formData.get('makeandmodel')!.toString(),
			imei: formData.get('imei')!.toString()
		}).returning())[0];

		ev.cookies.set('phoneSaleId', phoneSale.id + '', { path: '/' });
		return {
			registered: true,
			customerId: phoneSale.customerId,
			phoneSale
		};
	}
};
