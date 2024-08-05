<script>
	import { Button, Input, Label } from 'flowbite-svelte';

	// Prep form fields
	const formFields = [
		{ label: 'Full Name', value: 'Piet' },
		{ label: 'ID or Passport number', value: '1234' },
		{ label: 'Date of Birth', placeholder: 'YYYY-MM-DD', value: '1980-01-01' },
		{ label: 'Phone number', value: '4321' }
	].map(field => ({
		...field,
		value: field.value || 'sample-text',
		id: field.label.toLowerCase().replace(/ /g, '')
	}));

	/** @type HTMLFormElement */
	let form;

	function onSubmit() {
		const inputs = form.querySelectorAll('input');
		for (let i = 0; i < inputs.length; i++) {
			inputs[i].name = formFields[i].id;
		}
		form.submit();
	}
</script>

<svelte:head>
	<title>Yellow Mobile</title>
</svelte:head>

<h1 class="text-3xl mb-4">Yellow Mobile</h1>

<form method="POST" action="/register" bind:this={form}>
	{#each formFields as field}
		<div class="mb-4">
			<Label class="block">{field.label}</Label>
			<Input placeholder={field.placeholder} bind:value={field.value} />
		</div>
	{/each}

	<div class="">
		<Button on:click={onSubmit}>Register</Button>
	</div>
	<div class="bg-primary-700" style="display: none;" />
</form>
