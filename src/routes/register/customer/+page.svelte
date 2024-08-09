<script>
	import { Alert, Button } from 'flowbite-svelte';
	import { browser } from '$app/environment';

	/** @type {import('./$types').ActionData} */
	export let form;
	/** @type {import('./$types').PageData} */
	export let data;
	const pageData = form ? form : data;
</script>

{#if pageData?.approved}
	<Alert color="green" class="bg-green-200">
		<p class="font-medium text-lg">{pageData?.customer?.fullName}</p>
		<p>Registered successfully.</p>
	</Alert>
{/if}
{#if !pageData?.approved}
	<Alert color="red" class="bg-red-200">
		<p class="font-medium">Registration failed.</p>
		<p>{pageData?.reason}</p>
	</Alert>
{/if}

<div class="mt-6 rounded-full">
	<Button href="/?signout=true" pill>Sign Out</Button>
	{#if pageData?.approved}
		<Button href="/register/device" pill disabled={!browser}>Register Device</Button>
	{/if}
</div>
