import type { Config } from 'tailwindcss'


export default {
  content: [
    `app/frontend/**/*.{vue,js}`,
    `${process.env.FAE_PATH}/app/frontend/**/*.{vue,js}`,
  ],
  theme: {
    extend: {
      spacing: {
        '4xs': 'var(--space-4xs)',
        '3xs': 'var(--space-3xs)',
        '2xs': 'var(--space-2xs)',
        xs: 'var(--space-xs)',
        s: 'var(--space-s)',
        m: 'var(--space-m)',
        l: 'var(--space-l)',
        xl: 'var(--space-xl)',
        '2xl': 'var(--space-2xl)',
        '3xl': 'var(--space-3xl)',
        '4xl': 'var(--space-4xl)',
        '5xl': 'var(--space-5xl)',
        'page-padding': 'var(--space-page-padding)',
        'half-page-padding': 'var(--space-half-page-padding)',
        'large-margin': 'var(--space-large-margin)',
        'nav-height': 'var(--space-nav-height)',
      },
    },
    colors: {
      // These colors are mapped to variables defined in ~/assets/stylesheets/global/colors.css
      red: 'rgb(var(--c-red-rgb) / <alpha-value>)',
      black: 'rgb(var(--c-black-rgb) / <alpha-value>)',
      dark: 'rgb(var(--c-dark-rgb) / <alpha-value>)',
      grey: 'rgb(var(--c-grey-rgb) / <alpha-value>)',
      light: 'rgb(var(--c-light-rgb) / <alpha-value>)',
      white: 'rgb(var(--c-white-rgb) / <alpha-value>)',
      inherit: 'inherit',
      transparent: 'transparent',
      current: 'currentColor',
    },
    screens: {
      sm: '390px',
      md: '600px',
      lg: '1000px',
      xl: '1920px',
      // Note: Order of definition changes CSS output, keep these reversed to allow overriding of
      // larger breakpoints with smaller ones
      '-xl': { max: '1919px' },
      '-lg': { max: '999px' },
      '-md': { max: '599px' },
      '-sm': { max: '389px' },
    },
  },
  plugins: [],
}

