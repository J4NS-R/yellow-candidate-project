import { Logger } from '$lib/logging';
import { db } from '$lib/server/db';
import * as schema from '$lib/server/schema';
import { redirect } from '@sveltejs/kit';
import { env } from '$env/dynamic/private';
import { eq } from 'drizzle-orm';

const MIN_AGE = parseInt(env.VITE_MIN_AGE);
const MAX_AGE = parseInt(env.VITE_MAX_AGE);

const log = new Logger('/register/customer.server');


/**
 * @returns null if approved, or a reason as string if denied.
 */
function approveOrDeny(dob: Date): string | null {
	const age = (new Date().getTime() - dob.getTime()) / (1000 * 60 * 60 * 24 * 365.25);
	const approved = age >= MIN_AGE && age <= MAX_AGE;
	return approved ? null : 'Sorry, we cannot sell to your age group.';
}

/**
 * Runs server-side before sending the HTTP response
 */
export async function load(ev) {
	if (ev.request.method === 'GET') {
		if (ev.cookies.get('registered') !== 'true') {
			redirect(302, '/');
		}
		const id = parseInt(ev.cookies.get('customerId')!);
		const customer = await db.query.customersTable.findFirst({ where: eq(schema.customersTable.id, id) });
		if (!customer) {
			return { approved: false, reason: 'Unable to locate customer details. Try clearing your cookies.' };
		}
		return {
			customer,
			approved: customer.approved,
			reason: approveOrDeny(new Date(customer.dob))
		};
	}
}

export const actions = {
	default: async (event) => {
		const formData = await event.request.formData();
		log.debug('Attempting to register new customer');

		const dob = new Date(formData.get('dateofbirth')!.toString());
		if (isNaN(dob.valueOf())) {
			return { reason: `Bad date: ${formData.get('dateofbirth')?.toString()}`, approved: false };
		}

		const reason = approveOrDeny(dob);

		const newCustomer = (await db.insert(schema.customersTable).values({
			fullName: formData.get('fullname')!.toString(),
			idOrPassportNo: formData.get('idorpassportnumber')!.toString(),
			dob: dob.toISOString().substring(0, 10),
			phone: formData.get('phonenumber')!.toString(),
			approved: reason === null
		}).returning())[0];

		log.debug(`Customer registered with approved=${newCustomer.approved} and id=${newCustomer.id}`);
		event.cookies.set('registered', 'true', { path: '/' });
		event.cookies.set('customerId', newCustomer.id + '', { path: '/' });

		return {
			approved: newCustomer.approved,
			reason,
			customer: newCustomer
		};
	}
};
