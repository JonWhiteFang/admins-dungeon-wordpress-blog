# Requirements Document

## Introduction

This document specifies the requirements for deploying and managing a production-ready WordPress blog on AWS Lightsail in the EU (London) region using Infrastructure as Code (CloudFormation) and Model Context Protocol (MCP) servers. The system enables automated deployment, configuration, monitoring, and maintenance of a WordPress blog with SSL/HTTPS support, automated backups, security hardening, and performance optimization.

## Glossary

- **CloudFormation Stack**: AWS service that provisions and manages infrastructure resources using declarative templates
- **Lightsail Instance**: AWS managed virtual private server optimized for simple web applications
- **Static IP**: Persistent public IP address that remains constant across instance restarts
- **MCP Server**: Model Context Protocol server that provides automated access to AWS documentation and expertise
- **SSL Certificate**: Digital certificate that enables HTTPS encryption for secure web traffic
- **Bitnami Stack**: Pre-configured WordPress installation package with Apache, MySQL, and PHP
- **Snapshot**: Point-in-time backup of a Lightsail instance
- **User Data Script**: Initialization script that executes when an instance first launches
- **DNS Zone**: Hosted zone that manages domain name system records for a domain
- **WP-CLI**: Command-line interface for managing WordPress installations
- **CloudWatch Alarm**: Monitoring alert that triggers when metrics exceed defined thresholds

## Requirements

### Requirement 1

**User Story:** As a DevOps engineer, I want to deploy WordPress infrastructure using CloudFormation templates, so that deployments are reproducible and version-controlled

#### Acceptance Criteria

1. THE CloudFormation Stack SHALL create a Lightsail Instance with the WordPress blueprint in the us-east-1 region
2. THE CloudFormation Stack SHALL accept parameters for instance name, instance plan, availability zone, domain name, admin email, and snapshot configuration
3. THE CloudFormation Stack SHALL validate that the instance name contains only lowercase letters, numbers, and hyphens
4. THE CloudFormation Stack SHALL validate that the admin email matches the pattern for valid email addresses
5. THE CloudFormation Stack SHALL output the instance name, static IP address, WordPress URL, admin URL, and SSH command

### Requirement 2

**User Story:** As a system administrator, I want the WordPress instance to have a persistent static IP address, so that the site remains accessible at the same address after restarts

#### Acceptance Criteria

1. THE CloudFormation Stack SHALL create a Static IP resource in the us-east-1 region
2. THE CloudFormation Stack SHALL attach the Static IP to the Lightsail Instance
3. THE CloudFormation Stack SHALL name the Static IP using the pattern "{InstanceName}-static-ip"
4. THE CloudFormation Stack SHALL export the Static IP address value for cross-stack references

### Requirement 3

**User Story:** As a security engineer, I want the instance to have properly configured firewall rules, so that only necessary ports are exposed to the internet

#### Acceptance Criteria

1. THE Lightsail Instance SHALL allow inbound TCP traffic on port 22 from any IP address for SSH access
2. THE Lightsail Instance SHALL allow inbound TCP traffic on port 80 from any IP address for HTTP access
3. THE Lightsail Instance SHALL allow inbound TCP traffic on port 443 from any IP address for HTTPS access
4. THE Lightsail Instance SHALL block all other inbound traffic by default

### Requirement 4

**User Story:** As a site owner, I want to configure a custom domain with SSL certificate, so that visitors can access my blog securely using my domain name

#### Acceptance Criteria

1. WHERE a domain name parameter is provided, THE CloudFormation Stack SHALL create a DNS Zone for the domain
2. WHERE a domain name parameter is provided, THE CloudFormation Stack SHALL create an A record pointing the apex domain to the Static IP address
3. WHERE a domain name parameter is provided, THE CloudFormation Stack SHALL create an A record pointing the www subdomain to the Static IP address
4. WHERE a domain name parameter is provided, THE CloudFormation Stack SHALL create an SSL Certificate for the domain and www subdomain
5. WHERE a domain name parameter is provided, THE CloudFormation Stack SHALL output the nameserver values for domain registrar configuration

### Requirement 5

**User Story:** As a system administrator, I want the WordPress instance to be automatically configured on first launch, so that manual setup steps are minimized

#### Acceptance Criteria

1. WHEN the Lightsail Instance launches, THE User Data Script SHALL wait 60 seconds for Bitnami initialization to complete
2. WHEN the Lightsail Instance launches, THE User Data Script SHALL update all system packages
3. WHEN the Lightsail Instance launches, THE User Data Script SHALL set WordPress directory permissions to 755 for directories and 644 for files
4. WHEN the Lightsail Instance launches, THE User Data Script SHALL configure PHP memory limit to 256 megabytes
5. WHEN the Lightsail Instance launches, THE User Data Script SHALL configure PHP upload max filesize to 64 megabytes
6. WHEN the Lightsail Instance launches, THE User Data Script SHALL configure PHP post max size to 64 megabytes
7. WHEN the Lightsail Instance launches, THE User Data Script SHALL configure PHP max execution time to 300 seconds
8. WHEN the Lightsail Instance launches, THE User Data Script SHALL restart Apache and PHP-FPM services
9. WHEN the Lightsail Instance launches, THE User Data Script SHALL create a backup directory at /opt/bitnami/backups
10. WHEN the Lightsail Instance launches, THE User Data Script SHALL log completion timestamp to /var/log/wordpress-init.log

### Requirement 6

**User Story:** As a site owner, I want automated daily backups of my WordPress instance, so that I can recover from data loss or corruption

#### Acceptance Criteria

1. WHERE automatic snapshots are enabled, THE CloudFormation Stack SHALL configure daily snapshots at 03:00 UTC
2. THE Lightsail Instance SHALL retain the 7 most recent automatic snapshots
3. THE Lightsail Instance SHALL allow creation of manual snapshots on demand
4. THE Lightsail Instance SHALL name snapshots with a timestamp suffix in YYYYMMDD format

### Requirement 7

**User Story:** As a security engineer, I want WordPress security plugins installed and configured, so that the site is protected against common attacks

#### Acceptance Criteria

1. THE WordPress installation SHALL include the Wordfence security plugin in activated state
2. THE WordPress installation SHALL include the Limit Login Attempts Reloaded plugin in activated state
3. THE WordPress installation SHALL include the UpdraftPlus backup plugin in activated state
4. THE WordPress installation SHALL have all core files, plugins, and themes updated to latest versions
5. THE WordPress installation SHALL have a custom administrator account created with a strong password
6. THE WordPress installation SHALL have the default "user" account removed after reassigning content to the new administrator

### Requirement 8

**User Story:** As a site owner, I want WordPress performance optimization configured, so that my blog loads quickly for visitors

#### Acceptance Criteria

1. THE WordPress installation SHALL include the WP Super Cache plugin in activated state with caching enabled
2. THE WordPress installation SHALL include the Smush image optimization plugin in activated state
3. WHERE Redis is installed, THE WordPress installation SHALL include the Redis Cache plugin in activated state with Redis enabled

### Requirement 9

**User Story:** As a DevOps engineer, I want CloudWatch monitoring and alarms configured, so that I am notified of performance issues

#### Acceptance Criteria

1. THE Lightsail Instance SHALL publish CPU utilization metrics to CloudWatch
2. THE Lightsail Instance SHALL have a CloudWatch alarm named "wordpress-high-cpu" that triggers when CPU utilization exceeds 80 percent for 2 consecutive evaluation periods
3. THE Lightsail Instance SHALL publish network in and network out metrics to CloudWatch

### Requirement 10

**User Story:** As a DevOps engineer, I want to update the CloudFormation stack to modify instance configuration, so that I can scale resources without manual intervention

#### Acceptance Criteria

1. THE CloudFormation Stack SHALL support updates to the instance plan parameter
2. WHEN the instance plan parameter is updated, THE CloudFormation Stack SHALL modify the Lightsail Instance to use the new bundle size
3. THE CloudFormation Stack SHALL preserve the Static IP attachment during stack updates
4. THE CloudFormation Stack SHALL preserve all data and configuration during stack updates

### Requirement 11

**User Story:** As a DevOps engineer, I want to delete the CloudFormation stack cleanly, so that all resources are removed and costs stop accruing

#### Acceptance Criteria

1. WHEN the CloudFormation Stack is deleted, THE CloudFormation Stack SHALL remove the Lightsail Instance
2. WHEN the CloudFormation Stack is deleted, THE CloudFormation Stack SHALL remove the Static IP
3. WHERE a domain was configured, WHEN the CloudFormation Stack is deleted, THE CloudFormation Stack SHALL remove the DNS Zone
4. WHERE an SSL certificate was created, WHEN the CloudFormation Stack is deleted, THE CloudFormation Stack SHALL remove the SSL Certificate
5. THE CloudFormation Stack SHALL allow creation of a final manual snapshot before deletion

### Requirement 12

**User Story:** As a DevOps engineer, I want MCP servers configured for AWS documentation access, so that I can quickly retrieve relevant information during deployment and troubleshooting

#### Acceptance Criteria

1. THE MCP configuration SHALL include the aws-docs server using the uvx command with awslabs.aws-documentation-mcp-server package
2. THE MCP configuration SHALL include the aws-core server using the uvx command with mcp-aws-core package
3. THE MCP configuration SHALL auto-approve search_documentation and read_documentation tools for the aws-docs server
4. THE MCP configuration SHALL auto-approve prompt_understanding tool for the aws-core server
5. THE MCP configuration SHALL set FASTMCP_LOG_LEVEL to ERROR for the aws-docs server

### Requirement 13

**User Story:** As a system administrator, I want automation scripts for health checks and backup verification, so that I can monitor system status without manual checks

#### Acceptance Criteria

1. THE deployment SHALL include a daily health check script that queries instance state
2. THE deployment SHALL include a daily health check script that retrieves CPU utilization metrics for the previous hour
3. THE deployment SHALL include a weekly backup verification script that lists the 7 most recent snapshots
4. THE health check script SHALL output instance state as text
5. THE backup verification script SHALL output snapshot details in JSON format

### Requirement 14

**User Story:** As a site owner, I want SSL/HTTPS configured with Let's Encrypt certificates, so that my blog is secure and trusted by browsers

#### Acceptance Criteria

1. WHERE a custom domain is configured, THE WordPress installation SHALL use the Bitnami bncert-tool to obtain Let's Encrypt SSL certificates
2. WHERE a custom domain is configured, THE WordPress installation SHALL configure automatic certificate renewal
3. WHERE a custom domain is configured, THE WordPress installation SHALL redirect HTTP traffic to HTTPS
4. WHERE a custom domain is configured, THE WordPress installation SHALL set WP_HOME constant to the HTTPS domain URL
5. WHERE a custom domain is configured, THE WordPress installation SHALL set WP_SITEURL constant to the HTTPS domain URL

### Requirement 15

**User Story:** As a DevOps engineer, I want to retrieve WordPress admin credentials securely, so that I can access the admin panel after deployment

#### Acceptance Criteria

1. THE Lightsail Instance SHALL store the initial WordPress admin password in the file /home/bitnami/bitnami_application_password
2. THE WordPress admin password file SHALL be readable only by the bitnami user
3. THE CloudFormation Stack outputs SHALL include the SSH command required to connect to the instance
4. THE CloudFormation Stack outputs SHALL include the WordPress admin URL
