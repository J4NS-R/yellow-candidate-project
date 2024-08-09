import { redirect } from '@sveltejs/kit';
import { Logger } from '$lib/logging';
import type { PageServerLoadEvent } from './$types';

const log = new Logger('/.server');

export function load(ev: PageServerLoadEvent) {
	if (ev.url.searchParams.get('signout')) {
		log.debug('Clearing cookie.');
		ev.cookies.delete('registered', { path: '/' });
	} else if (ev.cookies.get('registered')) {
		log.debug('Customer already registered. Redirecting.');
		redirect(302, '/register/customer');
	}
}
