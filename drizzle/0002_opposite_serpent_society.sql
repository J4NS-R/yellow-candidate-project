CREATE TABLE IF NOT EXISTS "payments" (
	"sale_id" integer NOT NULL,
	"payment_id" text NOT NULL,
	"status" varchar(20)
);
--> statement-breakpoint
ALTER TABLE "phone_sales" ALTER COLUMN "customer_id" SET NOT NULL;--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "payments" ADD CONSTRAINT "payments_sale_id_phone_sales_id_fk" FOREIGN KEY ("sale_id") REFERENCES "public"."phone_sales"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
