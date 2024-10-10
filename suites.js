export const suites = {
    smoke: ['./../test/specs/**/*smoke.spec.js'],
    booking: [
      '../test/specs/housingOptions/housingOptionShortlisting.sanity.spec.js',
      '../test/specs/housingOptions/housingOptionSkipShortlisting.spec.js',
      '../test/specs/landing/featuredCities.spec.js',
      '../test/specs/ruleEngine/booking.spec.js',
    ],
    discover: ['../test/specs/ruleEngine/discover.spec.js'],
    pricing: [
      '../test/specs/booking/currency.spec.js',
      '../test/specs/discover/currencies.spec.js',
      '../test/specs/discover/pricing*.js',
      '../test/specs/stay/*.spec.js',
    ],
  };