import type { RollupOptions } from 'rollup';
import dev from 'rollup-plugin-dev';
import html from '@rollup/plugin-html';
import terser from '@rollup/plugin-terser';
import copy from 'rollup-plugin-copy';

const config = (args: Record<string, any>): RollupOptions => ({
	input: 'src/index.mjs',
	output: {
		dir: 'dist',
		format: 'es'
	},
    plugins: [
        copy({
            targets: [
                { src: 'static/**/*', dest: 'dist' }
            ],
        }),
        html({
            title: "44ko",
            meta: [
                { charset: 'utf-8' },
                { property: 'og:type', content: 'website' },
                { property: 'og:title', content: '44ko' },
                { property: 'og:description', content: 'A content-aware manga reader' },
                { property: 'og:url', content: 'https://unrelatedstring.github.io/44ko/' },
                { property: 'og:image', content: 'https://avatars.githubusercontent.com/u/33167175' },
            ],
            attributes: {
                html: { lang: 'en' },
                link: { rel: 'icon', href: 'favicon.ico' },
            },
        }),
        dev({
            dirs: ["dist"],
            force: args.configServe,
        }),
        terser(),
    ],
});
export default config;
