# Codecov Setup Guide

This document explains how to set up Codecov integration for the typstwriter.nvim project.

## Overview

The project is configured to upload coverage reports to Codecov automatically via GitHub Actions. The CI workflow generates coverage reports using LuaCov and uploads them to Codecov for tracking and badge display.

## Setup Steps

### 1. Create Codecov Account
1. Go to [codecov.io](https://codecov.io)
2. Sign up/login with your GitHub account
3. Add the `gl1tchc0d3r/typstwriter.nvim` repository

### 2. Get Repository Token
1. In Codecov dashboard, navigate to your repository
2. Go to **Settings** → **General**
3. Copy the **Repository Upload Token**

### 3. Add GitHub Secret
1. Go to GitHub repository: `https://github.com/gl1tchc0d3r/typstwriter.nvim`
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `CODECOV_TOKEN`
5. Value: Paste the token from step 2
6. Click **Add secret**

### 4. Verify Integration
Once the token is added:
1. Push changes or create a PR to trigger CI
2. Check that the CI workflow completes successfully
3. Verify coverage reports appear in Codecov dashboard
4. Confirm the coverage badge displays properly in README

## Current CI Configuration

The project uses **codecov-action@v5** with the following configuration:

```yaml
- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v5
  with:
    files: ./luacov.report.out
    flags: unittests
    name: neovim-${{ matrix.neovim-version }}
    fail_ci_if_error: false
    verbose: true
  env:
    CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

## Coverage Generation

Coverage reports are generated using:
1. **LuaCov** for Lua code coverage analysis
2. **Makefile target**: `make test-coverage` runs tests with coverage
3. **Output file**: `luacov.report.out` (ignored by git, generated during CI)

## Badge URL

The coverage badge in the README uses:
```markdown
[![codecov](https://codecov.io/gh/gl1tchc0d3r/typstwriter.nvim/branch/main/graph/badge.svg)](https://codecov.io/gh/gl1tchc0d3r/typstwriter.nvim)
```

This should display the current coverage percentage once Codecov is properly configured.

## Troubleshooting

### Badge Shows "unknown"
- Repository not added to Codecov
- Missing or incorrect `CODECOV_TOKEN` secret
- Coverage reports not being generated or uploaded

### Upload Failures
- Check GitHub Actions logs for error messages
- Verify the `luacov.report.out` file is being generated
- Ensure the token has proper permissions

### Coverage Not Updating
- Check that pushes to `main` and `staging` branches trigger CI
- Verify coverage reports are being uploaded successfully
- Coverage may take a few minutes to update in Codecov dashboard

## Additional Configuration

The project also uploads coverage from the comprehensive CI pipeline:
```yaml
- name: Upload coverage from CI pipeline  
  uses: codecov/codecov-action@v5
  with:
    files: ./luacov.report.out
    flags: ci-pipeline
    name: full-ci-pipeline
```

This provides additional coverage data from the complete CI run.
