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

export interface InternalPaymentRequest {
	phoneSaleId: number,
	customerId: number,
}

export interface TelcoPaymentRequest {
	idOrPassport: string,
	amountMinor: number,
}

export interface TelcoPaymentResponse {
	paymentStatus: PaymentStatus,
	paymentId: string,
}

export type PaymentStatus = 'unstarted' | 'processing' | 'approved' | 'rejected';
