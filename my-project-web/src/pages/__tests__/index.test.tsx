import React from 'react';
import { render, screen } from '@testing-library/react';
import { MockedProvider } from '@apollo/client/testing';
import IndexPage from '../index';

describe('IndexPage', () => {
  it('renders welcome message', () => {
    render(
      <MockedProvider mocks={[]} addTypename={false}>
        <IndexPage />
      </MockedProvider>
    );

    expect(screen.getByText('Welcome to My Project')).toBeInTheDocument();
  });

  it('shows loading state initially', () => {
    render(
      <MockedProvider mocks={[]} addTypename={false}>
        <IndexPage />
      </MockedProvider>
    );

    expect(screen.getByText('Loading...')).toBeInTheDocument();
  });
});
