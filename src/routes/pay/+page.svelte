<script>
	import { Alert, Button } from 'flowbite-svelte';
	import { writable } from 'svelte/store';
	import { CheckCircleSolid, InfoCircleOutline } from 'flowbite-svelte-icons';
	import { Logger } from '$lib/logging';
	import { onMount } from 'svelte';
	import { env } from '$env/dynamic/public';

	const log = new Logger('/pay.client');

	/** @type {import('./$types').PageData} */
	export let data;

	// On mount, open websocket client
	onMount(() => {
		const port = env.PUBLIC_DEBUG ? 3000 : window.location.port;
		log.debug(`Connecting to websocket on port ${port}`);
		const ws = new WebSocket(`ws://${window.location.hostname}:${port}`);

		ws.onopen = () => {
			const payload = JSON.stringify({
				customerId: data.phoneSale?.customerId,
				phoneSaleId: data.phoneSale?.id
			});
			log.debug(`Sending over ws: ${payload}`);
			ws.send(payload);
		};
		ws.onmessage = (/** @type {MessageEvent}*/ ev) => {
			log.debug(`Received message: ${ev.data}`);
			const body = JSON.parse(ev.data);
			state.set({
				paymentStatus: body.paymentStatus
			});
		};
	});

	/**
	 * Convert minor denomination to 2-decimal currency string
	 */
	function getAmount() {
		const amountMinor = data.phoneSale?.amountMinor || -1;
		return (amountMinor / 100).toFixed(2);
	}

	// TODO get status from db
	export const state = writable({
		paymentStatus: 'unstarted'
	});
</script>

<h2 class="text-lg">Settle Account</h2>

{#if $state.paymentStatus === 'unstarted'}
	<Alert color="gray" class="bg-gray-200">
		<InfoCircleOutline slot="icon" class="w-8 h-8" />
		<p>Outstanding amount: R{getAmount()}</p>
	</Alert>
{/if}
{#if $state.paymentStatus === 'approved'}
	<Alert color="green" class="bg-green-200">
		<CheckCircleSolid slot="icon" class="w-8 h-8" />
		<p>Payment Approved: R{getAmount()}</p>
	</Alert>
{/if}

<!-- TODO Submit Payment Button; Loading Icon -->

<div class="mt-6">
	<Button href="/">Home</Button>
</div>
