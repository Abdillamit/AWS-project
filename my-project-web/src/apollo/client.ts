import { ApolloClient, InMemoryCache, HttpLink, ApolloLink } from '@apollo/client';

// Get configuration from environment variables
const GRAPHQL_ENDPOINT = process.env.GATSBY_GRAPHQL_ENDPOINT || '';
const API_KEY = process.env.GATSBY_API_KEY || '';

const httpLink = new HttpLink({
  uri: GRAPHQL_ENDPOINT,
});

const authLink = new ApolloLink((operation, forward) => {
  // Add API key to headers
  operation.setContext({
    headers: {
      'x-api-key': API_KEY,
    },
  });
  return forward(operation);
});

export const apolloClient = new ApolloClient({
  link: authLink.concat(httpLink),
  cache: new InMemoryCache(),
  defaultOptions: {
    watchQuery: {
      fetchPolicy: 'cache-and-network',
    },
  },
});
