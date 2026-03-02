AWS Working Best Practices Guide

1. Tagging Requirements

- All resources must include mandatory tags: Environment, Project, Owner, CostCenter.

- Tags must be applied at creation time; untagged resources are not allowed.

- Tags must follow standard naming and capitalization conventions (e.g., Environment=dev/staging/prod).

2. Naming Convention

- Resource names must follow the pattern: <project>-<env>-<resource>-<sequence>.

- Use lowercase and hyphens only. No spaces or underscores.

- Example: analytics-dev-ec2-01

3. Minimum Resource Specification

- All compute, database, and storage resources must start with the approved minimum specification.

- Resources can be scaled up only when required and must be justified by workload needs.

- Unused or overscaled resources must be right-sized regularly.

4. Region Standardization

- The default and mandatory AWS region is ap-southeast-1 (Singapore).

- No resources may be created in other regions unless approved by the cloud governance team.

5. Networking Standards

- All projects will share a common VPC but operate in separate private subnets.

- All resources must be deployed strictly within private subnets.

- No resource may be exposed directly to the internet.

- Security Groups must deny open access (0.0.0.0/0) for all inbound rules.

- Inbound and outbound rules must be explicitly defined and restricted.

6. Remote Access Policy

- Direct SSH/RDP access is not allowed.

- AWS Systems Manager (SSM) Session Manager must be used for all remote access operations.

7. Identity and Access Management (IAM)

- Access keys must not be created for users or applications.

- Applications must use IAM Roles for authentication and permissions.

- CI/CD pipelines must authenticate using OIDC instead of long-lived credentials.

8. Infrastructure Provisioning

- All resources must be provisioned using Terraform.

- All changes must be tracked through version control and reviewed before deployment.

- Manual creation of cloud resources is not permitted unless explicitly approved.

9. Resource Scheduling

- All non-production compute resources must have automated stop schedules at the end of each working day.

- Resources not required during non-business hours must be shut down automatically.

10. Cost Responsibility and Governance

- Each project owner is fully responsible for costs incurred by their project resources.

- Any cost overrun must be justified and resolved by the project owner.

- Regular cost reviews must be conducted to prevent budget overruns.