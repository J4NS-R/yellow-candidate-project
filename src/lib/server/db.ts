import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import { env } from '$env/dynamic/private';
import * as schema from './schema';


const client = postgres(
	`postgres://${env.VITE_PG_USER}:${env.VITE_PG_PASS}@${env.VITE_PG_HOST}:5432/${env.VITE_PG_DB}`
);

export const db = drizzle(client, { schema });
