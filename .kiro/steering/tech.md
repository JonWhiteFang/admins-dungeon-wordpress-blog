---
inclusion: always
---

# Technology Stack & Commands

## Stack Overview

**Infrastructure**: AWS Lightsail (us-east-1) | CloudFormation (YAML) | Let's Encrypt SSL
**Application**: WordPress (Bitnami) | Apache 2.4 | MySQL | PHP | WP Super Cache/Redis
**Tools**: AWS CLI | WP-CLI | Bash | CloudWatch

## Required AWS CLI Patterns

**Always include `--region us-east-1`** in CloudFormation commands.

**Stack Operations**:
```bash
# Create
aws cloudformation create-stack --stack-name wordpress-blog-prod \
  --template-body file://templates/lightsail-wordpress.yaml \
  --parameters ParameterKey=InstanceName,ParameterValue=wordpress-blog-prod-us-east-1 \
  --region us-east-1

# Monitor status
aws cloudformation describe-stacks --stack-name wordpress-blog-prod \
  --region us-east-1 --query "Stacks[0].StackStatus"

# Wait for completion
aws cloudformation wait stack-create-complete --stack-name wordpress-blog-prod --region us-east-1

# Get outputs (connection details)
aws cloudformation describe-stacks --stack-name wordpress-blog-prod \
  --region us-east-1 --query "Stacks[0].Outputs"

# Update
aws cloudformation update-stack --stack-name wordpress-blog-prod \
  --template-body file://templates/lightsail-wordpress.yaml --region us-east-1

# Delete
aws cloudformation delete-stack --stack-name wordpress-blog-prod --region us-east-1
```

**Template Validation** (always run before deployment):
```bash
aws cloudformation validate-template --template-body file://templates/lightsail-wordpress.yaml
```

## WordPress Management (SSH)

All WP-CLI commands run as `bitnami` user:
```bash
sudo -u bitnami wp core update
sudo -u bitnami wp plugin update --all
sudo -u bitnami wp plugin install <name> --activate
```

## Script Validation

Test bash syntax before execution:
```bash
bash -n scripts/<category>/<script-name>.sh
```

## MCP Server Usage

**Use MCP tools instead of shell commands when available:**
- AWS documentation queries → `mcp_aws_docs_search_documentation`, `mcp_aws_docs_read_documentation`
- AWS expert guidance → `mcp_aws_core_prompt_understanding` (call first for AWS questions)
- File operations → Filesystem MCP tools (see mcp-server-usage.md)

**Required servers** in `.kiro/settings/mcp.json`:
- `aws-docs` (awslabs.aws-documentation-mcp-server)
- `aws-core` (mcp-aws-core)

## Key Constraints

- Region locked to `us-east-1` (N. Virginia)
- Stack name: `wordpress-blog-prod`
- Instance naming: `{InstanceName}-{resource-type}`
- Template path: `templates/lightsail-wordpress.yaml`
- All infrastructure changes go through CloudFormation (no manual AWS console edits)
