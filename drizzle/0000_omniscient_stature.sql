CREATE TABLE IF NOT EXISTS "customers" (
	"id" serial PRIMARY KEY NOT NULL,
	"full_name" text NOT NULL,
	"id_passport" text NOT NULL,
	"dob" date NOT NULL,
	"phone" text NOT NULL,
	"registration_date" timestamp DEFAULT now() NOT NULL,
	"approved" boolean DEFAULT false NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "phone_sales" (
	"id" serial PRIMARY KEY NOT NULL,
	"customer_id" integer,
	"sale_date" timestamp DEFAULT now() NOT NULL,
	"amount_minor" integer NOT NULL,
	"currency" varchar(3) NOT NULL,
	"make" text NOT NULL,
	"model" text NOT NULL,
	"imei" text
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "phone_sales" ADD CONSTRAINT "phone_sales_customer_id_customers_id_fk" FOREIGN KEY ("customer_id") REFERENCES "public"."customers"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
