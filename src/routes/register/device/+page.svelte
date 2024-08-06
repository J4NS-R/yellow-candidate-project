<script>
	import { Alert, Button } from 'flowbite-svelte';
	import SimpleForm from '$lib/client/simple-form.svelte';
	import { CheckCircleSolid } from 'flowbite-svelte-icons';
	import { getAmount } from '$lib/common';

	/** @type {import('./$types').PageData} */
	export let data;
	/** @type {import('./$types').ActionData} */
	export let form;
	const pageData = data ? data : form;

	/** @type {import('$lib/types.js').SimpleFormProps} */
	const registerDeviceFormDetails = {
		fields: [{
			label: 'customerid',
			hidden: true,
			value: data.customerId + ''
		}, {
			label: 'Amount (ZAR)',
		}, {
			label: 'Make and Model',
		}, {
			label: 'IMEI',
		}],
		buttonText: 'Register Device',
		postPath: '/register/device'
	};
</script>

<h2 class="text-lg mb-6">Register Device</h2>

{#if pageData?.registered}
	<Alert color="green" class="bg-green-200">
		<CheckCircleSolid slot="icon" class="w-8 h-8 mr-3" />
		<p>Your {pageData?.phoneSale?.makeAndModel} is registered.</p>
		<p>Value: R{getAmount(pageData?.phoneSale)}</p>
	</Alert>
{/if}

{#if !pageData?.registered}
	<SimpleForm props={registerDeviceFormDetails} />
{/if}

<div class="mt-12">
	<Button href="/">Home</Button>
	{#if pageData?.registered}
		<Button href="/pay">Pay Back</Button>
	{/if}
</div>
