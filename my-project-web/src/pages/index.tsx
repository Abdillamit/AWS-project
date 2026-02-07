import React from 'react';
import { useQuery, gql } from '@apollo/client';
import styled from 'styled-components';
import { Layout } from '../components/Layout';

const HELLO_QUERY = gql`
  query Hello {
    hello {
      message
      stage
      timestamp
    }
  }
`;

const Card = styled.div`
  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 30px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
`;

const Title = styled.h2`
  color: #282c34;
  margin-bottom: 20px;
`;

const Message = styled.p`
  font-size: 18px;
  color: #333;
  margin: 10px 0;
`;

const Badge = styled.span`
  display: inline-block;
  background: #61dafb;
  color: #282c34;
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 14px;
  font-weight: bold;
`;

const LoadingSpinner = styled.div`
  text-align: center;
  padding: 40px;
  color: #666;
`;

const ErrorMessage = styled.div`
  background: #fee;
  border: 1px solid #fcc;
  color: #c33;
  padding: 20px;
  border-radius: 8px;
`;

const IndexPage: React.FC = () => {
  const { data, loading, error } = useQuery(HELLO_QUERY);

  return (
    <Layout>
      <Card>
        <Title>Welcome to My Project</Title>

        {loading && <LoadingSpinner>Loading...</LoadingSpinner>}

        {error && (
          <ErrorMessage>
            <strong>Error:</strong> {error.message}
            <br />
            <small>Make sure the GraphQL API is deployed and configured.</small>
          </ErrorMessage>
        )}

        {data?.hello && (
          <>
            <Message>
              <strong>Message:</strong> {data.hello.message}
            </Message>
            <Message>
              <strong>Environment:</strong> <Badge>{data.hello.stage || 'prod'}</Badge>
            </Message>
            <Message>
              <strong>Timestamp:</strong> {new Date(data.hello.timestamp).toLocaleString()}
            </Message>
          </>
        )}
      </Card>
    </Layout>
  );
};

export default IndexPage;

export const Head = () => <title>My Project - Home</title>;
