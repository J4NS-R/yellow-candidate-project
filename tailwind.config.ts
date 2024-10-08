import type { Config } from 'tailwindcss';
import flowbite from 'flowbite/plugin';

export default {
	content: ['./src/**/*.{html,js,svelte,ts}', './node_modules/flowbite/**/*.js'],

	theme: {
		extend: {
			colors: {
				primary: {
					'50': '#fefce8',
					'100': '#fef9c3',
					'200': '#fef08a',
					'300': '#fde047',
					'400': '#facc15',
					'500': '#eab308',
					'600': '#ca8a04',
					'700': '#a16207',
					'800': '#854d0e',
					'900': '#713f12'
				}

			}
		}
	},

	plugins: [flowbite]
} as Config;
