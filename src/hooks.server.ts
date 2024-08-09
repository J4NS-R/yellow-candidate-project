// This code runs on server startup
import { db } from '$lib/server/db';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import { Logger } from '$lib/logging';

const log = new Logger('hooks.server.ts');


log.debug('Starting DB migration...');
await migrate(db, { migrationsFolder: './drizzle' });
log.info('Migrations complete');
