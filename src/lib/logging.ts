// Why add a dependency when you can make a logger in less than a kb?
export class Logger {
	prefix: string;

	constructor(prefix: string) {
		this.prefix = prefix;
	}

	info(message: string) {
		console.log(this.prefix, 'INFO', message);
	}

	debug(message: string) {
		console.log(this.prefix, 'DEBUG', message);
	}

	warn(message: string) {
		console.log(this.prefix, 'WARN', message);
	}

	error(message: string) {
		console.log(this.prefix, 'ERROR', message);
	}
}
