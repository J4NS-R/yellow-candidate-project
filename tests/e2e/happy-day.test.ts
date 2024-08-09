import { type APIRequestContext, type BrowserContext, expect, test } from '@playwright/test';
import * as fs from 'node:fs/promises';
import { db } from './test-db';
import { paymentsTable, phoneSalesTable } from '$lib/server/schema';
import { eq } from 'drizzle-orm';
import type { TelcoPaymentResponse } from '$lib/types';


let cookiePath: string;
let apiContext: APIRequestContext;

// Setup API
test.beforeAll(async ({ playwright }) => {
	apiContext = await playwright.request.newContext({
		baseURL: 'http://localhost:5173',
		extraHTTPHeaders: {
			'Content-Type': 'application/json'
		}
	});
});

async function setupCookies(context: BrowserContext): Promise<number> {
	const storageData = JSON.parse((await fs.readFile(cookiePath)).toString());
	await context.addCookies(storageData.cookies);
	for (const cookie of storageData.cookies) {
		if (cookie.name === 'customerId') {
			return parseInt(cookie.value);
		}
	}
	throw Error('Could not find customerId in cookie!');
}

test('customer registration', async ({ page }) => {
	await page.goto('/');
	// expect heading
	await expect(page.getByRole('heading')).toHaveText('Yellow Mobile');
	const btn = page.getByRole('button', { name: 'Register' });
	await expect(btn).toBeEnabled();

	// Fill form
	await page.getByLabel('Full Name').fill('Koos van der Merwe');
	await page.getByLabel('ID or Passport number').fill('1234');
	await page.getByPlaceholder('YYYY-MM-DD').fill('1980-01-01');
	await page.getByLabel('Phone number').fill('012345');
	await btn.click();

	// Expect success registration
	await expect(page.getByText('Registered successfully.')).toBeVisible();

	// Store cookies
	cookiePath = test.info().project.outputDir + '/.auth/yellow.json';
	await page.context().storageState({ path: cookiePath });
});

test('device registration', async ({ page, context }) => {
	await setupCookies(context);
	await page.goto('/');
	// Should auto-redirect
	await expect(page.getByText('Registered successfully.')).toBeVisible();
	// Click register device
	let btn = page.getByRole('button', { name: 'Register Device' });
	await expect(btn).toBeEnabled();
	await btn.click();
	// Wait for device screen
	await expect(page.getByLabel('IMEI')).toBeVisible();
	await page.getByLabel('Amount (ZAR)').fill('1500.50');
	await page.getByLabel('Make and Model').fill('Nokia Lumia 9');
	await page.getByLabel('IMEI').fill('IMEI1234');
	// Click register
	btn = page.getByRole('button', { name: 'Register Device' });
	await expect(btn).toBeEnabled();
	await btn.click();
	// Expect success page
	await expect(page.getByText('Your Nokia Lumia 9 is registered.')).toBeVisible();
	// Store cookies
	await page.context().storageState({ path: cookiePath });
});

test('payback', async ({ page, context }) => {
	const customerId = await setupCookies(context);
	await page.goto('/register/device');
	await expect(page.getByText('Your Nokia Lumia 9 is registered.')).toBeVisible();

	// Navigate to payment page
	let btn = page.getByRole('button', { name: 'Pay Back' });
	await expect(btn).toBeEnabled();
	await btn.click();
	await expect(page.getByText('Settle Account')).toBeVisible();
	await expect(page.getByText('Outstanding amount: R1500.50')).toBeVisible();

	// Start payment flow
	btn = page.getByRole('button', { name: 'Pay Now' });
	await expect(btn).toBeEnabled();
	await btn.click();
	await expect(page.getByText('Processing payment')).toBeVisible();

	// Get payment data
	const dbData = await db.select().from(phoneSalesTable).where(eq(phoneSalesTable.customerId, customerId))
		.leftJoin(paymentsTable, eq(paymentsTable.saleId, phoneSalesTable.id)).limit(1);
	const paymentInfo = dbData[0].payments!;
	expect(paymentInfo.paymentStatus).toBe('processing');

	// Approve payment
	const apiResp = await apiContext.post('/api/payment/webhook', {
		data: {
			paymentId: paymentInfo.paymentId,
			paymentStatus: 'approved'
		} as TelcoPaymentResponse
	});
	expect(apiResp.status()).toBe(200);

	// Now confirm the frontend has updated
	await expect(page.getByText('Payment Approved: R1500.50')).toBeVisible();
});

test.afterAll(async () => {
	await apiContext.dispose();
});
