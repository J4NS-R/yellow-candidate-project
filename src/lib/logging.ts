// Why add a dependency when you can make a logger in less than a kb?

export class Logger {
	private readonly prefix: string;

	public constructor(prefix: string) {
		this.prefix = prefix;
	}

	public info(message: any) {
		console.info(this.prefix, message);
	}

	public debug(message: any) {
		console.debug(this.prefix, message);
	}

	public warn(message: any) {
		console.warn(this.prefix, message);
	}

	public error(message: any) {
		console.error(this.prefix, message);
	}
}
