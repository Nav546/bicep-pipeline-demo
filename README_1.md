# Bicep Deploy Pipeline Demo

This is a minimal example of how the manual steps you did in AZ-104 Lab 03 and Lab 04 turn into an automated real-world workflow.

## What's in here

- `main.bicep` - the template. This is the same idea as your az104-disk5.bicep file, just deploying Azure resources instead of doing it manually. This is the single source of truth for what gets built in Azure. It currently deploys:
  - A Storage Account (StorageV2, TLS 1.2 minimum, public blob access disabled)
  - A Virtual Network with one subnet (10.0.0.0/16, with a 10.0.1.0/24 subnet)
  - **CoreServicesVnet** (10.20.0.0/16) with SharedServicesSubnet and DatabaseSubnet
  - **ManufacturingVnet** (10.30.0.0/16) with SensorSubnet1 and SensorSubnet2t
  - An Application Security Group (**SensorVMsAsg**) to tag sensor VMs
  - A Network Security Group (**SensorSubnet1Nsg**) attached to SensorSubnet1, allowing inbound web traffic (ports 80/443) to VMs in the ASG, and denying outbound internet traffic

- `.github/workflows/deploy.yml` - the pipeline. This is a GitHub Actions workflow. Instead of you typing `az deployment group create` yourself like you did in the lab, this file tells GitHub: "whenever someone changes main.bicep and pushes it to the main branch, automatically log into Azure and deploy it."

- `lab04-networking.bicep` - the original standalone version of the Lab 04 networking resources (VNets, subnets, NSG, ASG), kept here as a reference. This file itself is **not** deployed by the pipeline; its contents have been merged into `main.bicep` above, which is what actually deploys.

## How the flow actually works, step by step

1. You edit `main.bicep` (change a SKU, add a resource, whatever the task needs).
2. You commit and push that change to GitHub.
3. GitHub Actions sees the change matches the "paths" filter in deploy.yml and automatically starts the job.
4. The pipeline logs into Azure using credentials stored as encrypted GitHub Secrets (never hardcoded, never visible in the file).
5. It runs the equivalent of your CLI command: `az deployment group create --resource-group demo-rg --template-file main.bicep`
