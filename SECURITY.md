# Security Policy

## Supported Versions

We release patches for security vulnerabilities for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

We take the security of this project seriously. If you discover a security vulnerability, please follow these steps:

### 1. Do Not Disclose Publicly

Please do not open a public GitHub issue for security vulnerabilities.

### 2. Report Privately

Send an email to the maintainers with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### 3. Response Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Timeline**: Depends on severity
  - Critical: Within 7 days
  - High: Within 14 days
  - Medium: Within 30 days
  - Low: Next release cycle

## Security Best Practices

### For Deployment

1. **AWS Credentials**
   - Never commit AWS credentials to the repository
   - Use IAM roles with least privilege
   - Rotate credentials regularly
   - Enable MFA on AWS accounts

2. **SSH Access**
   - Restrict SSH access to specific IP addresses
   - Use strong SSH keys (4096-bit RSA or Ed25519)
   - Never share private keys
   - Rotate SSH keys periodically

3. **WordPress Security**
   - Change default admin password immediately
   - Remove default "user" account
   - Keep WordPress, plugins, and themes updated
   - Use strong passwords (16+ characters)
   - Enable two-factor authentication

4. **SSL/TLS**
   - Always use HTTPS in production
   - Keep SSL certificates up to date
   - Use strong cipher suites
   - Enable HSTS headers

5. **Firewall Rules**
   - Restrict SSH (port 22) to known IPs
   - Keep HTTP (80) and HTTPS (443) open for web traffic
   - Block all other ports
   - Review firewall rules regularly

### For Development

1. **Code Review**
   - Review all CloudFormation template changes
   - Check for hardcoded credentials
   - Validate parameter constraints
   - Test in isolated environment

2. **Dependencies**
   - Keep AWS CLI updated
   - Use official AWS CloudFormation resources
   - Verify script sources
   - Review third-party integrations

3. **Testing**
   - Test in non-production environment first
   - Validate all security controls
   - Test backup and restore procedures
   - Verify monitoring and alerting

## Known Security Considerations

### CloudFormation Template

- **SSH Access**: Default configuration allows SSH from any IP (0.0.0.0/0)
  - **Recommendation**: Update firewall rules to restrict to your IP
  - **How**: Modify the InstanceFirewall resource in the template

- **Default Admin User**: Bitnami creates a default "user" account
  - **Recommendation**: Create new admin user and delete default
  - **How**: Use WP-CLI commands in post-deployment

### WordPress Configuration

- **File Permissions**: User data script sets standard permissions
  - **Recommendation**: Review and adjust based on security requirements
  - **How**: SSH to instance and modify with chmod/chown

- **Database Access**: MySQL accessible only from localhost
  - **Status**: Secure by default
  - **Note**: No external database access

### Backup Security

- **Snapshot Access**: Snapshots stored in your AWS account
  - **Recommendation**: Enable AWS account MFA
  - **Recommendation**: Use AWS Organizations for access control

- **Backup Encryption**: Lightsail snapshots encrypted at rest
  - **Status**: Enabled by default
  - **Note**: Uses AWS-managed keys

## Security Updates

We will announce security updates through:
- GitHub Security Advisories
- CHANGELOG.md updates
- Release notes

## Compliance

This project follows:
- AWS Well-Architected Framework Security Pillar
- OWASP WordPress Security Guidelines
- CIS Benchmarks for WordPress

## Additional Resources

- [AWS Lightsail Security](https://docs.aws.amazon.com/lightsail/latest/userguide/understanding-lightsail-security.html)
- [WordPress Security](https://wordpress.org/support/article/hardening-wordpress/)
- [Bitnami Security](https://docs.bitnami.com/aws/security/)
- [Let's Encrypt Best Practices](https://letsencrypt.org/docs/)
