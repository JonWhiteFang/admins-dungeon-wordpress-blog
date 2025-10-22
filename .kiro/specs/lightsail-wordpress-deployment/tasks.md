# Implementation Plan

- [x] 1. Create CloudFormation template structure and parameters
  - Create lightsail-wordpress.yaml file with AWSTemplateFormatVersion and Description
  - Define Parameters section with InstanceName, InstancePlan, AvailabilityZone, DomainName, AdminEmail, and EnableAutomaticSnapshots
  - Add parameter validation patterns and constraints
  - Define Conditions section for HasDomain and EnableSnapshots
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2. Implement Lightsail instance resource
  - Define WordPressInstance resource with AWS::Lightsail::Instance type
  - Configure BlueprintId as wordpress and BundleId from parameter
  - Set AvailabilityZone from parameter
  - Add tags for Environment, Application, ManagedBy, and Region
  - _Requirements: 1.1, 1.5_

- [x] 3. Create user data initialization script
  - Write bash script in UserData property with 60-second wait for Bitnami initialization
  - Add system package update commands (apt-get update && upgrade)
  - Implement WordPress directory permission settings (755 for directories, 644 for files)
  - Configure PHP settings (memory_limit, upload_max_filesize, post_max_size, max_execution_time)
  - Add Apache and PHP-FPM restart commands
  - Create backup directory at /opt/bitnami/backups
  - Add completion logging to /var/log/wordpress-init.log
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9, 5.10_

- [x] 4. Implement static IP resource and attachment
  - Define StaticIP resource with AWS::Lightsail::StaticIp type
  - Set StaticIpName using Sub function with pattern {InstanceName}-static-ip
  - Configure AttachedTo property to reference WordPressInstance
  - _Requirements: 2.1, 2.2, 2.3_

- [x] 5. Configure instance firewall rules
  - Define InstanceFirewall resource with AWS::Lightsail::Instance type
  - Add DependsOn for WordPressInstance
  - Configure Networking.Ports for SSH (port 22), HTTP (port 80), and HTTPS (port 443)
  - Set Cidrs to 0.0.0.0/0 for all ports
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [x] 6. Implement conditional DNS zone resource
  - Define DNSZone resource with AWS::Lightsail::Domain type
  - Add Condition: HasDomain
  - Configure DomainName from parameter
  - Add DomainEntries for apex domain A record pointing to StaticIP
  - Add DomainEntries for www subdomain A record pointing to StaticIP
  - _Requirements: 4.1, 4.2, 4.3_

- [x] 7. Implement conditional SSL certificate resource
  - Define SSLCertificate resource with AWS::Lightsail::Certificate type
  - Add Condition: HasDomain
  - Set CertificateName using Sub function with pattern {InstanceName}-ssl-cert
  - Configure DomainName from parameter
  - Add SubjectAlternativeNames for www subdomain
  - Add ManagedBy tag
  - _Requirements: 4.4_

- [ ] 8. Create CloudFormation outputs
  - Define InstanceName output with export name
  - Define StaticIPAddress output using GetAtt function with export name
  - Define WordPressURL output using Sub function with HTTP protocol
  - Define WordPressAdminURL output using Sub function with /wp-admin path
  - Define SSHCommand output with SSH key path and bitnami user
  - Define conditional DomainNameServers output with Lightsail nameservers
  - Define NextSteps output with multi-line post-deployment instructions
  - _Requirements: 1.5, 2.4, 4.5, 15.3, 15.4_

- [ ] 9. Create MCP server configuration file
  - Create or update .kiro/settings/mcp.json file
  - Add aws-docs server configuration with uvx command and awslabs.aws-documentation-mcp-server package
  - Configure FASTMCP_LOG_LEVEL environment variable to ERROR
  - Add autoApprove array with search_documentation and read_documentation
  - Add aws-core server configuration with uvx command and mcp-aws-core package
  - Add autoApprove array with prompt_understanding
  - Set disabled to false for both servers
  - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5_

- [ ] 10. Create deployment automation scripts
  - Write deploy-stack.sh script with aws cloudformation create-stack command
  - Include all required parameters (instance name, plan, zone, email, domain, snapshots)
  - Add stack monitoring command (describe-stacks with StackStatus query)
  - Add stack wait command (wait stack-create-complete)
  - Write get-outputs.sh script to retrieve and display stack outputs
  - _Requirements: 1.1, 1.2_

- [ ] 11. Create WordPress configuration scripts
  - Write get-admin-password.sh script with SSH command to retrieve bitnami_application_password
  - Write configure-ssl.sh script with bncert-tool commands for Let's Encrypt
  - Write update-wp-config.sh script to add WP_HOME and WP_SITEURL constants
  - Include HTTPS protocol in WordPress URL constants
  - _Requirements: 14.1, 14.3, 14.4, 14.5, 15.1, 15.2_

- [ ] 12. Create security hardening scripts
  - Write install-security-plugins.sh script with WP-CLI commands
  - Add wp plugin install commands for wordfence, limit-login-attempts-reloaded, and updraftplus
  - Add --activate flag to each plugin install command
  - Write update-wordpress.sh script with wp core update, wp plugin update --all, and wp theme update --all
  - Write create-admin-user.sh script with wp user create command for new admin
  - Add wp user delete command to remove default "user" account with --reassign flag
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

- [ ] 13. Create performance optimization scripts
  - Write install-caching.sh script with WP-CLI commands for wp-super-cache
  - Add wp super-cache enable command
  - Add wp plugin install command for smush with --activate flag
  - Write install-redis.sh script with apt-get install redis-server
  - Add systemctl enable redis-server command
  - Add WP-CLI commands for redis-cache plugin installation and activation
  - Add wp redis enable command
  - _Requirements: 8.1, 8.2, 8.3_

- [ ] 14. Create backup configuration scripts
  - Write enable-snapshots.sh script with aws lightsail enable-add-on command
  - Configure AutoSnapshot add-on with snapshotTimeOfDay at 03:00
  - Write verify-snapshots.sh script with aws lightsail get-auto-snapshots command
  - Write create-manual-snapshot.sh script with aws lightsail create-instance-snapshot command
  - Include timestamp suffix in YYYYMMDD format using date command
  - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 15. Create monitoring configuration scripts
  - Write enable-monitoring.sh script with aws lightsail put-instance-metric-data command
  - Write create-alarms.sh script with aws lightsail put-alarm command
  - Configure wordpress-high-cpu alarm with CPUUtilization metric
  - Set comparison operator to GreaterThanThreshold with threshold 80
  - Set evaluation periods to 2
  - _Requirements: 9.1, 9.2, 9.3_

- [ ] 16. Create health check automation script
  - Write daily-health-check.sh script with instance name and region variables
  - Add aws lightsail get-instance-state command with query for state.name
  - Add aws lightsail get-instance-metric-data command for CPUUtilization
  - Configure metric query for past 1 hour with 3600 second period
  - Set statistics to Average and unit to Percent
  - Add echo statements for output formatting
  - _Requirements: 13.1, 13.2, 13.4_

- [ ] 17. Create backup verification automation script
  - Write verify-backups.sh script with instance name and region variables
  - Add aws lightsail get-instance-snapshots command
  - Configure query to filter by fromInstanceName and limit to 7 most recent
  - Format output as JSON
  - _Requirements: 13.3, 13.5_

- [ ] 18. Create stack management scripts
  - Write update-stack.sh script with aws cloudformation update-stack command
  - Include template-body and parameters arguments
  - Write delete-stack.sh script with snapshot creation before deletion
  - Add aws lightsail create-instance-snapshot command with final-backup naming
  - Add aws cloudformation delete-stack command
  - Write export-template.sh script with aws cloudformation get-template command
  - Configure query for TemplateBody and output to file
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 11.1, 11.2, 11.3, 11.4, 11.5_

- [ ] 19. Create deployment documentation
  - Write README.md with deployment overview and prerequisites
  - Document all deployment phases with time estimates
  - Include troubleshooting section with common issues and solutions
  - Add cost estimation breakdown
  - Include post-deployment checklist
  - Document MCP server usage examples
  - _Requirements: All requirements_

- [ ] 20. Create validation and testing scripts
  - Write validate-template.sh script with aws cloudformation validate-template command
  - Write test-user-data.sh script with bash -n syntax check
  - Write test-deployment.sh script for end-to-end deployment testing
  - Include verification steps for each component
  - Add cleanup commands for test resources
  - _Requirements: All requirements_
