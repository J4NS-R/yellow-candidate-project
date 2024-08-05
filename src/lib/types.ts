export interface FormField {
	label: string;
	value?: string;
	placeholder?: string;
	id?: string;
	hidden?: boolean;
}

export interface SimpleFormProps {
	fields: FormField[];
	postPath: string;
	buttonText: string;
}
