<script>
	import SimpleForm from '$lib/client/simple-form.svelte';

	// Prep form fields
	/** @type {import('$lib/types').SimpleFormProps} */
	const formConfig = {
		fields: [
			{ label: 'Full Name', value: 'Piet' },
			{ label: 'ID or Passport number', value: '1234' },
			{ label: 'Date of Birth', placeholder: 'YYYY-MM-DD', value: '1980-01-01' },
			{ label: 'Phone number', value: '4321' }
		],
		postPath: '/register/customer',
		buttonText: 'Register'
	};
</script>

<svelte:head>
	<title>Yellow Mobile</title>
</svelte:head>

<h1 class="text-3xl mb-4">Yellow Mobile</h1>

<SimpleForm props={formConfig} />
