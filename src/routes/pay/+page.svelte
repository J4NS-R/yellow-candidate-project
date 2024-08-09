<script>
	import { Alert, Button, Spinner } from 'flowbite-svelte';
	import { writable } from 'svelte/store';
	import { CheckCircleOutline, ExclamationCircleOutline, InfoCircleOutline } from 'flowbite-svelte-icons';
	import { Logger } from '$lib/logging';
	import { onMount } from 'svelte';
	import { env } from '$env/dynamic/public';
	import { getAmount } from '$lib/common';
	import { browser } from '$app/environment';

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
				customerId: data.phoneSale.customerId,
				phoneSaleId: data.phoneSale.id
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

	// Setup state
	export const state = writable({
		paymentStatus: data.paymentStatus
	});
	log.debug('paymentStatus: ' + $state.paymentStatus);

	async function startPayment() {
		/** @type {import('$lib/types').InternalPaymentRequest}*/
		const paymentRequest = {
			phoneSaleId: data.phoneSale.id,
			customerId: data.phoneSale.customerId
		};

		log.debug(`Requesting payment for saleId=${paymentRequest.phoneSaleId}`);
		const resp = await fetch(`${window.location.protocol}//${window.location.hostname}:${window.location.port}/api/payment/init`, {
			method: 'POST',
			body: JSON.stringify(paymentRequest)
		});

		if (resp.status === 202) {
			log.debug(`Payment status: ${resp.status}`);
			/** @type {import('$lib/types').TelcoPaymentResponse}*/
			const respBody = await resp.json();
			state.set({
				paymentStatus: respBody.paymentStatus
			});
		} else {
			// TODO handle
			log.error('Payment request failed');
		}
	}
</script>

<h2 class="text-lg mb-4">Settle Account</h2>

{#if $state.paymentStatus === 'unstarted'}
	<Alert color="gray" class="bg-gray-200">
		<InfoCircleOutline slot="icon" class="w-8 h-8 mr-3" />
		<p>Outstanding amount: R{getAmount(data.phoneSale)}</p>
	</Alert>
	<div class="mt-6">
		<Button on:click={startPayment} disabled={!browser}>Pay Now</Button>
	</div>
{/if}

{#if $state.paymentStatus === 'processing'}
	<Alert color="gray" class="bg-gray-200">
		<Spinner slot="icon" class="fill-yellow-400 animate-spin" color="yellow" size={8} />
		<p class="ml-3">Processing payment</p>
	</Alert>
	<div class="mt-6">
		<Button on:click={() => state.set({paymentStatus: 'unstarted'})}>Cancel</Button>
	</div>
{/if}

{#if $state.paymentStatus === 'rejected'}
	<Alert color="red" class="bg-red-200">
		<ExclamationCircleOutline slot="icon" class="w-8 h-8" />
		<p>Payment rejected.</p>
	</Alert>
	<div class="mt-6">
		<Button on:click={() => state.set({paymentStatus: 'unstarted'})}>Restart</Button>
	</div>
{/if}

{#if $state.paymentStatus === 'approved'}
	<Alert color="green" class="bg-green-200">
		<CheckCircleOutline slot="icon" class="w-8 h-8" />
		<p>Payment Approved: R{getAmount(data.phoneSale)}</p>
	</Alert>
{/if}

<div class="mt-6">
	<Button href="/">Home</Button>
</div>
