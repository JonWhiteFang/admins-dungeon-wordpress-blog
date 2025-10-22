# Technology Stack

## Infrastructure

- **Cloud Provider**: AWS (eu-west-2 region)
- **Compute**: AWS Lightsail instances
- **IaC**: AWS CloudFormation (YAML templates)
- **DNS**: Lightsail DNS zones
- **SSL**: Let's Encrypt via Bitnami bncert-tool

## Application Stack

- **CMS**: WordPress (Bitnami stack)
- **Web Server**: Apache 2.4
- **Database**: MySQL
- **Runtime**: PHP
- **Caching**: WP Super Cache, Redis (optional)

## Automation & Tools

- **CLI**: AWS CLI, WP-CLI
- **Scripting**: Bash
- **Documentation**: MCP AWS Documentation Server, MCP AWS Core Server
- **Monitoring**: AWS CloudWatch

## Common Commands

### Deployment
```bash
# Create stack
aws cloudformation create-stack --stack-name wordpress-blog-prod --template-body file://lightsail-wordpress.yaml --parameters ParameterKey=InstanceName,ParameterValue=wordpress-blog-prod-eu-west-2 --region eu-west-2

# Monitor stack creation
aws cloudformation describe-stacks --stack-name wordpress-blog-prod --region eu-west-2 --query "Stacks[0].StackStatus"

# Wait for completion
aws cloudformation wait stack-create-complete --stack-name wordpress-blog-prod --region eu-west-2
```

### Management
```bash
# Get stack outputs
aws cloudformation describe-stacks --stack-name wordpress-blog-prod --region eu-west-2 --query "Stacks[0].Outputs"

# Update stack
aws cloudformation update-stack --stack-name wordpress-blog-prod --template-body file://lightsail-wordpress.yaml --region eu-west-2

# Delete stack
aws cloudformation delete-stack --stack-name wordpress-blog-prod --region eu-west-2
```

### WordPress Management (via SSH)
```bash
# Update WordPress core
sudo -u bitnami wp core update

# Update all plugins
sudo -u bitnami wp plugin update --all

# Install plugin
sudo -u bitnami wp plugin install plugin-name --activate
```

### Validation
```bash
# Validate CloudFormation template
aws cloudformation validate-template --template-body file://lightsail-wordpress.yaml

# Test bash script syntax
bash -n script-name.sh
```

## MCP Server Configuration

Required MCP servers in `.kiro/settings/mcp.json`:
- **aws-docs**: AWS documentation access (awslabs.aws-documentation-mcp-server)
- **aws-core**: AWS expert guidance (mcp-aws-core)
