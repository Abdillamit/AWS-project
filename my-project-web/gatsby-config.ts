import type { GatsbyConfig } from 'gatsby';

const config: GatsbyConfig = {
  siteMetadata: {
    title: 'My Project',
    description: 'Full-stack AWS application',
    siteUrl: process.env.GATSBY_STAGE === 'beta' 
      ? 'https://beta.mydomain.com' 
      : 'https://mydomain.com',
  },
  graphqlTypegen: true,
  plugins: [
    'gatsby-plugin-styled-components',
  ],
};

export default config;
