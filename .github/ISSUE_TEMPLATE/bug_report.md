---
name: Bug report
about: Create a report to help us improve
title: '[BUG] '
labels: bug
assignees: ''
---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Deploy stack with parameters '...'
2. Run command '...'
3. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**CloudFormation Stack Details**
- Stack Name: 
- Region: 
- Instance Plan: 
- Domain Configured: Yes/No

**Error Messages**
```
Paste any error messages here
```

**CloudFormation Events**
```bash
# Output of:
aws cloudformation describe-stack-events --stack-name YOUR_STACK_NAME --region eu-west-2
```

**Environment**
- OS: [e.g. Windows, macOS, Linux]
- AWS CLI Version: [e.g. 2.13.0]
- Template Version: [e.g. 1.0.0]

**Additional context**
Add any other context about the problem here.
