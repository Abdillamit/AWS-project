import React from 'react';
import { GatsbyBrowser } from 'gatsby';
import { ApolloProvider } from '@apollo/client';
import { Provider as ReduxProvider } from 'react-redux';
import { apolloClient } from './src/apollo/client';
import { store } from './src/redux/store';

export const wrapRootElement: GatsbyBrowser['wrapRootElement'] = ({ element }) => {
  return (
    <ReduxProvider store={store}>
      <ApolloProvider client={apolloClient}>
        {element}
      </ApolloProvider>
    </ReduxProvider>
  );
};
