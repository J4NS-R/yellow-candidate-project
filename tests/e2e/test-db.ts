import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';

const env = process.env;


const client = postgres(
	`postgres://${env.VITE_PG_USER}:${env.VITE_PG_PASS}@${env.VITE_PG_HOST}:5432/${env.VITE_PG_DB}`
);

export const db = drizzle(client);
