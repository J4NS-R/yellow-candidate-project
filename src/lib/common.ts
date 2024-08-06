/**
 * Convert minor denomination to 2-decimal currency string
 */
export function getAmount(phoneSale?: { amountMinor?: number }): string {
	const amountMinor = phoneSale?.amountMinor;
	if (!amountMinor) {
		return null;
	}
	return (amountMinor / 100).toFixed(2);
}
