import { expect, test } from '@playwright/test';


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
});
