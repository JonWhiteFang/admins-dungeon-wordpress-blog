# Contributing to AWS Lightsail WordPress Deployment

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Issues

- Check existing issues before creating a new one
- Provide detailed information about the problem
- Include CloudFormation stack events if relevant
- Specify your AWS region and instance configuration
- Include relevant log files or error messages

### Suggesting Enhancements

- Clearly describe the enhancement and its benefits
- Explain why this would be useful to most users
- Consider backward compatibility
- Provide examples of how it would work

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test your changes thoroughly
5. Commit with clear messages (`git commit -m 'Add amazing feature'`)
6. Push to your branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## Development Guidelines

### CloudFormation Templates

- Follow AWS CloudFormation best practices
- Validate templates before submitting: `aws cloudformation validate-template`
- Include parameter descriptions and constraints
- Add comments for complex logic
- Test in a clean AWS account

### Scripts

- Use bash for shell scripts
- Include error handling (`set -e`)
- Add comments for complex operations
- Test on both Linux and macOS if possible
- Follow shellcheck recommendations

### Documentation

- Update README.md for user-facing changes
- Update design.md for architectural changes
- Keep examples current and tested
- Use clear, concise language
- Include code examples where helpful

## Testing

Before submitting a PR:

1. **Validate CloudFormation template**
   ```bash
   aws cloudformation validate-template --template-body file://lightsail-wordpress.yaml
   ```

2. **Test deployment**
   - Deploy to a test AWS account
   - Verify all resources created successfully
   - Test WordPress accessibility
   - Verify SSL configuration (if applicable)
   - Test backup functionality

3. **Test scripts**
   ```bash
   bash -n script-name.sh  # Syntax check
   shellcheck script-name.sh  # Linting
   ```

4. **Test documentation**
   - Verify all links work
   - Ensure commands are accurate
   - Check formatting renders correctly

## Code Style

### CloudFormation YAML

- Use 2-space indentation
- Keep lines under 120 characters
- Group related resources together
- Use descriptive resource names
- Add inline comments for complex logic

### Bash Scripts

- Use 2-space indentation
- Quote variables: `"$VARIABLE"`
- Use `[[` instead of `[` for conditionals
- Include shebang: `#!/bin/bash`
- Add error handling: `set -e`

### Documentation

- Use Markdown formatting
- Keep lines under 100 characters
- Use code blocks with language tags
- Include examples for complex concepts
- Use tables for structured data

## Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and PRs when relevant
- Provide context in the body if needed

Example:
```
Add support for custom VPC configuration

- Add VPC parameter to CloudFormation template
- Update documentation with VPC examples
- Add validation for VPC CIDR blocks

Fixes #123
```

## Review Process

1. Automated checks run on all PRs
2. Maintainers review code and provide feedback
3. Address feedback and update PR
4. Once approved, maintainers will merge

## Questions?

Feel free to open an issue for questions or discussion.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
