<script>
	import { Alert } from 'flowbite-svelte';

	/** @type {import('./$types').ActionData} */
	export let form;
</script>

{#if form?.registered}
	<Alert>
		Registered!
	</Alert>
{/if}
