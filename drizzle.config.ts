import { defineConfig } from 'drizzle-kit';
import * as dotenv from 'dotenv';

dotenv.config({ path: '.env.local' });

// Generate SQL with `npm run drizzle-generate`
// Migration is done at app startup.

export default defineConfig({
	schema: './src/lib/server/schema.ts',
	out: './drizzle',
	dialect: 'postgresql',
	dbCredentials: {
		host: process.env.VITE_PG_HOST,
		user: process.env.VITE_PG_USER,
		password: process.env.VITE_PG_PASS,
		database: process.env.VITE_PG_DB
	}
});
