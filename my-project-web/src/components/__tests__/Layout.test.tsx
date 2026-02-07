import React from 'react';
import { render, screen } from '@testing-library/react';
import { Layout } from '../Layout';

describe('Layout', () => {
  it('renders children', () => {
    render(
      <Layout>
        <div>Test Content</div>
      </Layout>
    );

    expect(screen.getByText('Test Content')).toBeInTheDocument();
  });

  it('renders header', () => {
    render(
      <Layout>
        <div>Content</div>
      </Layout>
    );

    expect(screen.getByText('My Project')).toBeInTheDocument();
    expect(screen.getByText('Full-Stack AWS Application')).toBeInTheDocument();
  });

  it('renders footer with current year', () => {
    render(
      <Layout>
        <div>Content</div>
      </Layout>
    );

    const currentYear = new Date().getFullYear();
    expect(screen.getByText(new RegExp(`© ${currentYear}`))).toBeInTheDocument();
  });
});
