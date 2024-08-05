<script>
	import { Button, Input, Label } from 'flowbite-svelte';

	/** @type {import('../types').SimpleFormProps} */
	export let props;
	const formFields = props.fields.map(field => ({
		...field,
		value: field.value || 'sample-text',
		id: field.label.toLowerCase().replace(/[ ()]/g, '')
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

<form method="POST" action={props.postPath} bind:this={form}>
	{#each formFields as field}
		<div class="mb-4" class:hide={!!field.hidden}>
			<Label class="block">{field.label}</Label>
			<Input placeholder={field.placeholder} bind:value={field.value} />
		</div>
	{/each}

	<div class="">
		<Button on:click={onSubmit}>{props.buttonText}</Button>
	</div>
	<!-- flowbite bug -->
	<div class="bg-primary-700" style="display: none;" />
</form>

<style>
    .hide {
        display: none;
    }
</style>
