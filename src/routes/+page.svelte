<script>
	import SimpleForm from '$lib/client/simple-form.svelte';

	// Prep form fields
	/** @type {import('$lib/types').SimpleFormProps} */
	const formConfig = {
		fields: [
			{ label: 'Full Name' },
			{ label: 'ID or Passport number' },
			{ label: 'Date of Birth', placeholder: 'YYYY-MM-DD' },
			{ label: 'Phone number' }
		],
		postPath: '/register/customer',
		buttonText: 'Register'
	};
</script>

<h1 class="text-3xl mb-4">Yellow Mobile</h1>

<SimpleForm props={formConfig} />
