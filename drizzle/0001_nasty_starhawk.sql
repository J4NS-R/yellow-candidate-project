ALTER TABLE "customers" RENAME COLUMN "phone" TO "phone_number";--> statement-breakpoint
ALTER TABLE "phone_sales" ALTER COLUMN "currency" SET DEFAULT 'ZAR';--> statement-breakpoint
ALTER TABLE "phone_sales" ALTER COLUMN "currency" DROP NOT NULL;--> statement-breakpoint
ALTER TABLE "phone_sales" ALTER COLUMN "imei" SET NOT NULL;--> statement-breakpoint
ALTER TABLE "phone_sales" ADD COLUMN "make_model" text NOT NULL;--> statement-breakpoint
ALTER TABLE "phone_sales" DROP COLUMN IF EXISTS "make";--> statement-breakpoint
ALTER TABLE "phone_sales" DROP COLUMN IF EXISTS "model";