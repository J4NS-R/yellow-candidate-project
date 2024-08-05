import { boolean, date, integer, pgTable, serial, text, timestamp, varchar } from 'drizzle-orm/pg-core';
// https://orm.drizzle.team/docs/column-types/pg

export const customersTable = pgTable('customers', {
	id: serial('id').primaryKey(),
	fullName: text('full_name').notNull(),
	idOrPassportNo: text('id_passport').notNull(),
	dob: date('dob').notNull(),
	phone: text('phone_number').notNull(),
	registrationDate: timestamp('registration_date').notNull().defaultNow(),
	approved: boolean('approved').notNull().default(false)
});

export const phoneSalesTable = pgTable('phone_sales', {
	id: serial('id').primaryKey(),
	customerId: integer('customer_id').references(() => customersTable.id, { onDelete: 'cascade' }),
	saleDate: timestamp('sale_date').notNull().defaultNow(),
	amountMinor: integer('amount_minor').notNull(),
	currency: varchar('currency', { length: 3 }).default('ZAR'),
	makeAndModel: text('make_model').notNull(),
	imei: text('imei').notNull()
});
