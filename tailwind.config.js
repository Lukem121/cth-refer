module.exports = {
  purge: {
    enabled: !process.env.ROLLUP_WATCH,
    mode: 'all',
    content: ['./**/**/*.html', './**/**/*.svelte'],

    options: {
      whitelistPatterns: [/svelte-/],
      defaultExtractor: (content) =>
        [...content.matchAll(/(?:class:)*([\w\d-/:%.]+)/gm)].map(([_match, group, ..._rest]) => group),
    },
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      fontFamily: {
        sans: ['Roboto', 'sans-serif'],
      },
      colors:{
        'harvest-blue-dark': "#008F9E",
        'harvest-blue': "#00B5A6",
        'harvest-green-dark': "#43DB40",
        'harvest-green': "#50FA7B",
        'harvest-green-light': "#70FF98",
        'harvest-black': "#1A1A1D",
        'harvest-yello': "#F1C517",
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
