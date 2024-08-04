import { Logger } from '$lib/logging';
import { db } from '$lib/server/db';
import * as schema from '$lib/server/schema';
import { redirect } from '@sveltejs/kit';

const log = new Logger('/register.server');

export function load(ev) {
	if (ev.request.method === 'GET') {
		redirect(302, '/');
	}
}

export const actions = {
	default: async (event) => {
		const formData = await event.request.formData();
		log.debug('Attempting to register new customer');

		const newCustomer = (await db.insert(schema.customersTable).values({
			fullName: formData.get('fullname')?.toString(),
			idOrPassportNo: formData.get('idorpassportnumber')?.toString(),
			dob: formData.get('dateofbirth')?.toString(),
			phone: formData.get('phonenumber')?.toString()
		}).returning())[0];

		log.debug(`Customer registered with approved=${newCustomer.approved} and id=${newCustomer.id}`);
		return {
			registered: true,
			approved: newCustomer.approved,
			id: newCustomer.id
		};
	}
};
