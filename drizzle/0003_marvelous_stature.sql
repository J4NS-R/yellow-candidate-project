ALTER TABLE "payments" DROP CONSTRAINT "payments_sale_id_phone_sales_id_fk";
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "payments" ADD CONSTRAINT "payments_sale_id_phone_sales_id_fk" FOREIGN KEY ("sale_id") REFERENCES "public"."phone_sales"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
