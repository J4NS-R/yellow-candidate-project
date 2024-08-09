ALTER TABLE "payments" ADD PRIMARY KEY ("sale_id");--> statement-breakpoint
ALTER TABLE "payments" ALTER COLUMN "payment_id" SET DATA TYPE varchar(64);--> statement-breakpoint
ALTER TABLE "payments" ALTER COLUMN "status" SET DEFAULT 'unstarted';--> statement-breakpoint
ALTER TABLE "payments" ALTER COLUMN "status" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "payments" ADD CONSTRAINT "payments_payment_id_unique" UNIQUE("payment_id");