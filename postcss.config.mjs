/** @type {import('postcss-load-config').Config} */
const config = {
  plugins: {
    // Tailwind CSS 4.x uses @tailwindcss/postcss instead of the old tailwindcss plugin
    "@tailwindcss/postcss": {},
  },
};

export default config;
