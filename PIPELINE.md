# CI/CD Pipeline Setup Guide

This guide covers setting up AWS CodePipeline for automated deployments.

## Overview

The CI/CD pipeline will:
1. Monitor GitHub repositories for changes
2. Trigger on push to main branch
3. Build and test code
4. Deploy to beta environment automatically
5. Wait for manual approval
6. Deploy to production

## Prerequisites

1. GitHub repositories created:
   - `my-project-infrastructure`
   - `my-project-api`
   - `my-project-web`

2. GitHub Personal Access Token with repo permissions

3. AWS Secrets Manager secret for GitHub token

## Step 1: Store GitHub Token in AWS Secrets Manager

```bash
# Create secret for GitHub token
aws secretsmanager create-secret \
  --name GithubToken \
  --description "GitHub Personal Access Token for CodePipeline" \
  --secret-string "your-github-token-here" \
  --region us-west-2
```

Get the ARN:

```bash
aws secretsmanager describe-secret \
  --secret-id GithubToken \
  --region us-west-2 \
  --query 'ARN' \
  --output text
```

## Step 2: Update BuildSpec Files

Update the GitHub token ARN in all `buildspec.yml` files:

### my-project-infrastructure/buildspec.yml

```yaml
env:
  secrets-manager:
    GITHUB_TOKEN: arn:aws:secretsmanager:us-west-2:YOUR_ACCOUNT:secret:GithubToken-XXXXX
```

### my-project-api/buildspec.yml

```yaml
env:
  secrets-manager:
    GITHUB_TOKEN: arn:aws:secretsmanager:us-west-2:YOUR_ACCOUNT:secret:GithubToken-XXXXX
```

## Step 3: Create Pipeline Stack

Create `my-project-infrastructure/lib/stacks/pipeline-stack.ts`:

```typescript
import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as codepipeline from 'aws-cdk-lib/aws-codepipeline';
import * as codepipeline_actions from 'aws-cdk-lib/aws-codepipeline-actions';
import * as codebuild from 'aws-cdk-lib/aws-codebuild';
import { STAGE } from '../constructs/stages';

export interface PipelineStackProps extends cdk.StackProps {
  githubOwner: string;
  githubTokenSecretArn: string;
}

export class PipelineStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: PipelineStackProps) {
    super(scope, id, props);

    const { githubOwner, githubTokenSecretArn } = props;

    // Source artifacts
    const infraSourceOutput = new codepipeline.Artifact('InfraSource');
    const apiSourceOutput = new codepipeline.Artifact('ApiSource');
    const webSourceOutput = new codepipeline.Artifact('WebSource');

    // Build artifacts
    const infraBuildOutput = new codepipeline.Artifact('InfraBuild');
    const apiBuildOutput = new codepipeline.Artifact('ApiBuild');
    const webBuildOutput = new codepipeline.Artifact('WebBuild');

    // GitHub OAuth token
    const githubToken = cdk.SecretValue.secretsManager('GithubToken');

    // CodeBuild projects
    const infraBuildProject = new codebuild.PipelineProject(this, 'InfraBuild', {
      buildSpec: codebuild.BuildSpec.fromSourceFilename('buildspec.yml'),
      environment: {
        buildImage: codebuild.LinuxBuildImage.STANDARD_7_0,
      },
    });

    const apiBuildProject = new codebuild.PipelineProject(this, 'ApiBuild', {
      buildSpec: codebuild.BuildSpec.fromSourceFilename('buildspec.yml'),
      environment: {
        buildImage: codebuild.LinuxBuildImage.STANDARD_7_0,
      },
    });

    const webBuildProject = new codebuild.PipelineProject(this, 'WebBuild', {
      buildSpec: codebuild.BuildSpec.fromSourceFilename('buildspec.yml'),
      environment: {
        buildImage: codebuild.LinuxBuildImage.STANDARD_7_0,
      },
    });

    // Pipeline
    const pipeline = new codepipeline.Pipeline(this, 'Pipeline', {
      pipelineName: 'MyProject-Pipeline',
      crossAccountKeys: false,
    });

    // Source stage
    pipeline.addStage({
      stageName: 'Source',
      actions: [
        new codepipeline_actions.GitHubSourceAction({
          actionName: 'Infrastructure_Source',
          owner: githubOwner,
          repo: 'my-project-infrastructure',
          oauthToken: githubToken,
          output: infraSourceOutput,
          branch: 'main',
        }),
        new codepipeline_actions.GitHubSourceAction({
          actionName: 'API_Source',
          owner: githubOwner,
          repo: 'my-project-api',
          oauthToken: githubToken,
          output: apiSourceOutput,
          branch: 'main',
        }),
        new codepipeline_actions.GitHubSourceAction({
          actionName: 'Web_Source',
          owner: githubOwner,
          repo: 'my-project-web',
          oauthToken: githubToken,
          output: webSourceOutput,
          branch: 'main',
        }),
      ],
    });

    // Build stage
    pipeline.addStage({
      stageName: 'Build',
      actions: [
        new codepipeline_actions.CodeBuildAction({
          actionName: 'Build_Infrastructure',
          project: infraBuildProject,
          input: infraSourceOutput,
          outputs: [infraBuildOutput],
        }),
        new codepipeline_actions.CodeBuildAction({
          actionName: 'Build_API',
          project: apiBuildProject,
          input: apiSourceOutput,
          outputs: [apiBuildOutput],
        }),
        new codepipeline_actions.CodeBuildAction({
          actionName: 'Build_Web',
          project: webBuildProject,
          input: webSourceOutput,
          outputs: [webBuildOutput],
        }),
      ],
    });

    // Deploy to Beta stage
    pipeline.addStage({
      stageName: 'Deploy_Beta',
      actions: [
        new codepipeline_actions.CloudFormationCreateUpdateStackAction({
          actionName: 'Deploy_Beta_Storage',
          stackName: 'betaMyServiceStorageStack',
          templatePath: infraBuildOutput.atPath('betaMyServiceStorageStack.template.json'),
          adminPermissions: true,
        }),
        new codepipeline_actions.CloudFormationCreateUpdateStackAction({
          actionName: 'Deploy_Beta_Auth',
          stackName: 'betaMyServiceAuthStack',
          templatePath: infraBuildOutput.atPath('betaMyServiceAuthStack.template.json'),
          adminPermissions: true,
        }),
        new codepipeline_actions.CloudFormationCreateUpdateStackAction({
          actionName: 'Deploy_Beta_API',
          stackName: 'betaMyServiceAPIStack',
          templatePath: infraBuildOutput.atPath('betaMyServiceAPIStack.template.json'),
          adminPermissions: true,
        }),
      ],
    });

    // Manual approval
    pipeline.addStage({
      stageName: 'Approve_Production',
      actions: [
        new codepipeline_actions.ManualApprovalAction({
          actionName: 'Approve',
          additionalInformation: 'Review beta deployment before promoting to production',
        }),
      ],
    });

    // Deploy to Production stage
    pipeline.addStage({
      stageName: 'Deploy_Production',
      actions: [
        new codepipeline_actions.CloudFormationCreateUpdateStackAction({
          actionName: 'Deploy_Prod_Storage',
          stackName: 'MyServiceStorageStack',
          templatePath: infraBuildOutput.atPath('MyServiceStorageStack.template.json'),
          adminPermissions: true,
        }),
        new codepipeline_actions.CloudFormationCreateUpdateStackAction({
          actionName: 'Deploy_Prod_Auth',
          stackName: 'MyServiceAuthStack',
          templatePath: infraBuildOutput.atPath('MyServiceAuthStack.template.json'),
          adminPermissions: true,
        }),
        new codepipeline_actions.CloudFormationCreateUpdateStackAction({
          actionName: 'Deploy_Prod_API',
          stackName: 'MyServiceAPIStack',
          templatePath: infraBuildOutput.atPath('MyServiceAPIStack.template.json'),
          adminPermissions: true,
        }),
      ],
    });
  }
}
```

## Step 4: Add Pipeline to CDK App

Update `my-project-infrastructure/bin/projects/my-service/service.ts`:

```typescript
import { PipelineStack } from '../../../lib/stacks/pipeline-stack';

// ... existing code ...

// Add pipeline stack (deploy separately)
// Uncomment when ready to set up CI/CD
/*
new PipelineStack(app, 'MyProjectPipelineStack', {
  env,
  githubOwner: 'your-github-username',
  githubTokenSecretArn: 'arn:aws:secretsmanager:us-west-2:ACCOUNT:secret:GithubToken-XXXXX',
});
*/
```

## Step 5: Deploy Pipeline

```bash
cd my-project-infrastructure

# Build
npm run build

# Deploy pipeline stack
cdk deploy MyProjectPipelineStack
```

## Step 6: Test Pipeline

### Trigger Pipeline

Push a change to any of the repositories:

```bash
cd my-project-api
git add .
git commit -m "Test pipeline trigger"
git push origin main
```

### Monitor Pipeline

```bash
# View pipeline status
aws codepipeline get-pipeline-state \
  --name MyProject-Pipeline \
  --query 'stageStates[*].[stageName,latestExecution.status]' \
  --output table
```

Or use AWS Console:
1. Go to CodePipeline
2. Select "MyProject-Pipeline"
3. Watch stages execute

## Pipeline Stages

### 1. Source
- Pulls latest code from GitHub
- Triggers on push to main branch
- Creates source artifacts

### 2. Build
- Runs `npm install` and `npm run build`
- Executes tests
- Creates build artifacts
- Generates CloudFormation templates

### 3. Deploy Beta
- Deploys to beta environment
- Updates all stacks
- Runs automatically

### 4. Approve Production
- Manual approval gate
- Review beta deployment
- Approve or reject

### 5. Deploy Production
- Deploys to production
- Updates all stacks
- Runs after approval

## Monitoring and Notifications

### Set Up SNS Topic for Notifications

```bash
# Create SNS topic
aws sns create-topic --name MyProject-Pipeline-Notifications

# Subscribe your email
aws sns subscribe \
  --topic-arn arn:aws:sns:us-west-2:ACCOUNT:MyProject-Pipeline-Notifications \
  --protocol email \
  --notification-endpoint your-email@example.com
```

### Add CloudWatch Alarms

```typescript
// In pipeline-stack.ts
import * as sns from 'aws-cdk-lib/aws-sns';
import * as cloudwatch from 'aws-cdk-lib/aws-cloudwatch';
import * as cloudwatch_actions from 'aws-cdk-lib/aws-cloudwatch-actions';

const topic = new sns.Topic(this, 'PipelineNotifications');

pipeline.onStateChange('PipelineStateChange', {
  target: new targets.SnsTopic(topic),
});
```

## Troubleshooting

### Pipeline Fails at Source Stage

- Verify GitHub token is valid
- Check repository names match
- Ensure token has repo permissions

### Build Stage Fails

- Check CloudWatch Logs for CodeBuild
- Verify buildspec.yml is correct
- Check npm dependencies

### Deploy Stage Fails

- Check CloudFormation stack events
- Verify IAM permissions
- Check for resource conflicts

### Manual Approval Not Received

- Check SNS topic subscriptions
- Verify email is confirmed
- Check spam folder

## Best Practices

1. **Branch Strategy**
   - Use `main` for production-ready code
   - Use `develop` for integration
   - Create feature branches for development

2. **Testing**
   - Run tests locally before pushing
   - Add integration tests to pipeline
   - Use test coverage reports

3. **Rollback Strategy**
   - Keep previous versions in S3
   - Use CloudFormation change sets
   - Test rollback procedures

4. **Security**
   - Rotate GitHub tokens regularly
   - Use least privilege IAM roles
   - Enable CloudTrail logging

5. **Monitoring**
   - Set up CloudWatch dashboards
   - Configure alarms for failures
   - Monitor costs

## Advanced Configuration

### Add Integration Tests

Create a test stage between Build and Deploy:

```typescript
pipeline.addStage({
  stageName: 'Integration_Tests',
  actions: [
    new codepipeline_actions.CodeBuildAction({
      actionName: 'Run_Integration_Tests',
      project: integrationTestProject,
      input: apiBuildOutput,
    }),
  ],
});
```

### Add Multiple Environments

Add staging environment:

```typescript
pipeline.addStage({
  stageName: 'Deploy_Staging',
  actions: [/* staging deployment actions */],
});
```

### Parallel Deployments

Deploy multiple stacks in parallel:

```typescript
pipeline.addStage({
  stageName: 'Deploy_Beta',
  actions: [
    // These run in parallel
    storageDeployAction,
    authDeployAction,
    apiDeployAction,
  ],
});
```

## Cost Considerations

Pipeline costs:
- CodePipeline: $1/month per active pipeline
- CodeBuild: $0.005/build minute
- S3 artifact storage: ~$0.023/GB/month

Estimated monthly cost: $5-20 depending on usage

## Next Steps

1. ✅ Set up pipeline
2. ✅ Test with a commit
3. ✅ Configure notifications
4. ✅ Add integration tests
5. ✅ Document deployment process
6. ✅ Train team on approval process

## Resources

- [AWS CodePipeline Documentation](https://docs.aws.amazon.com/codepipeline/)
- [AWS CDK Pipeline Construct](https://docs.aws.amazon.com/cdk/api/v2/docs/aws-cdk-lib.pipelines-readme.html)
- [GitHub Actions Alternative](https://github.com/features/actions)
