# Contributing to Zed Debian Package Generator

Thank you for your interest in contributing to the Zed Debian Package Generator! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [Making Changes](#making-changes)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Testing](#testing)

## Code of Conduct

By participating in this project, you agree to maintain a respectful and inclusive environment for everyone.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR-USERNAME/zed-deb.git`
3. Add the original repository as upstream: `git remote add upstream https://github.com/ORIGINAL-OWNER/zed-deb.git`

## Development Environment Setup

Ensure you have the following dependencies installed:

```bash
sudo apt-get update
sudo apt-get install -y curl jq dpkg-dev fakeroot tar unzip
```

## Making Changes

1. Create a new branch: `git checkout -b feature/your-feature-name`
2. Make your changes
3. Test your changes (see [Testing](#testing) section)
4. Commit your changes with a descriptive commit message

## Pull Request Process

1. Update the README.md or documentation with details of changes if appropriate
2. Make sure your code passes all tests
3. Push your branch to your fork: `git push origin feature/your-feature-name`
4. Create a Pull Request from your fork to the original repository
5. Fill out the PR template with all required information
6. Wait for review and address any feedback

## Issue Reporting

When reporting issues, please include:

- A clear and descriptive title
- Steps to reproduce the issue
- Expected behavior
- Actual behavior
- Screenshots if applicable
- Your operating system and relevant software versions
- Any additional context

Use the issue templates when available.

## Testing

Before submitting your changes, please test:

1. The build script works correctly: `./build-deb.sh`
2. The created .deb package installs and runs properly
3. If you changed the GitHub Actions workflow, make sure it works as expected

Test on different Debian-based distributions if possible (Ubuntu, Debian, Linux Mint, etc.).

## Directory Structure

```
zed-deb/
├── .github/           # GitHub specific files (workflows, templates)
├── build-deb.sh       # Script to manually build .deb packages
├── README.md          # Project documentation
└── LICENSE            # Project license
```

## Versioning

This project follows the versioning scheme of the official Zed releases.

---

Thank you for contributing to the Zed Debian Package Generator!