# My Project Web

Frontend Gatsby application for My Project.

## Prerequisites

- Node.js 18+
- npm 10+

## Installation

```bash
npm install --legacy-peer-deps
```

## Configuration

Create a `.env.development` file:

```env
GATSBY_GRAPHQL_ENDPOINT=https://your-appsync-endpoint.appsync-api.us-west-2.amazonaws.com/graphql
GATSBY_API_KEY=your-api-key
GATSBY_STAGE=beta
```

Create a `.env.production` file:

```env
GATSBY_GRAPHQL_ENDPOINT=https://your-appsync-endpoint.appsync-api.us-west-2.amazonaws.com/graphql
GATSBY_API_KEY=your-api-key
GATSBY_STAGE=prod
```

## Development

```bash
npm run dev
```

Open [http://localhost:8000](http://localhost:8000)

## Build

### Beta

```bash
npm run build:beta
```

### Production

```bash
npm run build:prod
```

## Test

```bash
npm test
```

## Project Structure

```
src/
├── apollo/             # Apollo Client configuration
├── components/         # React components
│   ├── Layout.tsx
│   └── __tests__/
├── pages/             # Gatsby pages
│   ├── index.tsx
│   └── __tests__/
├── redux/             # Redux store
│   ├── store.ts
│   ├── reducers/
│   └── epics/
└── utils/             # Utility functions
```

## Tech Stack

- **Framework**: Gatsby 5.x with React 18
- **Language**: TypeScript
- **Styling**: Styled Components + Styletron
- **State Management**: Redux + Redux-Observable (RxJS)
- **GraphQL Client**: Apollo Client 3.x
- **Testing**: Jest + React Testing Library

## Deployment

The application is deployed to S3 and served via CloudFront. Deployment is handled by AWS CodePipeline.

## Environment Variables

- `GATSBY_GRAPHQL_ENDPOINT`: AppSync GraphQL API endpoint
- `GATSBY_API_KEY`: AppSync API key
- `GATSBY_STAGE`: Deployment stage (beta/prod)
