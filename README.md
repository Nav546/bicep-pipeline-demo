# Bicep Deploy Pipeline Demo

This is a minimal example of how the manual steps you did in AZ-104 Lab 03
turn into an automated real-world workflow.

## What's in here

- `main.bicep` - the template. This is the same idea as your az104-disk5.bicep
  file, just deploying a Storage Account instead of a Managed Disk. This is the
  single source of truth for what gets built in Azure.

- `.github/workflows/deploy.yml` - the pipeline. This is a GitHub Actions
  workflow. Instead of you typing `az deployment group create` yourself like
  you did in the lab, this file tells GitHub: "whenever someone changes
  main.bicep and pushes it to the main branch, automatically log into Azure
  and deploy it."

## How the flow actually works, step by step

1. You edit main.bicep (change a SKU, add a resource, whatever the task needs).
2. You commit and push that change to GitHub.
3. GitHub Actions sees the change matches the "paths" filter in deploy.yml
   and automatically starts the job.
4. The pipeline logs into Azure using credentials stored as encrypted GitHub
   Secrets (never hardcoded, never visible in the file).
5. It runs the equivalent of your CLI command:
   az deployment group create --resource-group demo-rg --template-file main.bicep
6. Azure Resource Manager deploys it - same engine, same result, as when you
   did it manually in the lab.

## Why this matters for your DevOps direction

This is the exact bridge from AZ-104 into DevOps/cloud engineering roles:
- AZ-104 teaches you the resource and the template.
- DevOps (AZ-400 territory, or just general practice) teaches you to wire
  that template into a pipeline so it deploys itself, consistently, every
  time, without someone remembering to run a command by hand.

## To actually try this yourself (optional, when ready)

1. Create a new GitHub repo and push these two files into it.
2. Create a Service Principal in Azure:
   az ad sp create-for-rbac --name "github-deploy-demo" --role Contributor \
     --scopes /subscriptions/<your-subscription-id>/resourceGroups/demo-rg \
     --sdk-auth
3. Copy the JSON output into a GitHub repo secret named AZURE_CREDENTIALS
   (Settings > Secrets and variables > Actions > New repository secret).
4. Add a second secret, AZURE_SUBSCRIPTION_ID, with your subscription ID.
5. Push a small change to main.bicep and watch the Actions tab in GitHub -
   you'll see the deployment run automatically.
