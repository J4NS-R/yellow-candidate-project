import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import { env } from '$env/dynamic/private';
import * as schema from './schema';
import { Logger } from '$lib/logging';

const log = new Logger('$lib/server/db');
log.info(`Creating database in NODE_ENV: ${env.NODE_ENV}`);

if (!env.VITE_PG_HOST || !env.VITE_PG_PASS) {
	log.error('Missing required VITE_PG_* env vars! DB migration will fail.');
}

const client = postgres(
	`postgres://${env.VITE_PG_USER}:${env.VITE_PG_PASS}@${env.VITE_PG_HOST}:5432/${env.VITE_PG_DB}`,
	{ ssl: env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : undefined }
);

export const db = drizzle(client, { schema });
