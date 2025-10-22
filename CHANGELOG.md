# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-22

### Added
- Initial release of AWS Lightsail WordPress deployment
- CloudFormation template for automated infrastructure provisioning
- Support for custom domains with DNS zone configuration
- SSL/TLS certificate integration with Let's Encrypt
- Automated daily snapshots with 7-day retention
- CloudWatch monitoring and alarms
- User data script for automatic instance configuration
- Automation scripts for deployment and maintenance:
  - deploy-stack.sh: Deploy CloudFormation stack
  - get-outputs.sh: Retrieve stack outputs
  - configure-ssl.sh: Configure SSL certificates
  - install-security-plugins.sh: Install security plugins
  - install-caching.sh: Install caching plugins
  - enable-snapshots.sh: Enable automatic snapshots
  - daily-health-check.sh: Check instance health
  - verify-backups.sh: Verify backup snapshots
- Comprehensive documentation:
  - README.md: Quick start guide
  - CONTRIBUTING.md: Contribution guidelines
  - Requirements document
  - Design document
  - Implementation tasks
- GitHub Actions workflow for template validation
- MIT License

### Security
- Firewall rules for SSH, HTTP, and HTTPS
- Support for Wordfence security plugin
- Support for Limit Login Attempts plugin
- SSL/HTTPS configuration via Bitnami bncert-tool

### Performance
- PHP configuration optimization (256M memory, 64M uploads)
- Support for WP Super Cache plugin
- Support for Smush image optimization
- Optional Redis object caching

## [Unreleased]

### Planned
- Multi-region deployment support
- CDN integration with CloudFront
- Advanced monitoring dashboards
- Automated WordPress updates
- Blue-green deployment support
- Cost optimization recommendations
