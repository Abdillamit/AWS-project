# My Project - Full-Stack AWS Application

A complete full-stack application with AWS services, CI/CD pipelines, and multi-environment setup.

## Project Structure

- `my-project-web/` - Frontend Gatsby application
- `my-project-api/` - Backend Lambda functions
- `my-project-infrastructure/` - AWS CDK infrastructure

## Environments

- **Beta**: Testing environment (beta.mydomain.com)
- **Prod**: Production environment (mydomain.com)

## Getting Started

### Prerequisites

- Node.js 18+ (20+ recommended)
- AWS CLI configured
- AWS CDK CLI: `npm install -g aws-cdk`

### Initial Setup

1. Install dependencies in each project:
```bash
cd my-project-infrastructure && npm install
cd ../my-project-api && npm install
cd ../my-project-web && npm install
```

2. Deploy infrastructure to beta:
```bash
cd my-project-infrastructure
npm run deploy:beta
```

3. Deploy to production:
```bash
npm run deploy:prod
```

## Development

See individual project READMEs for specific development instructions.
