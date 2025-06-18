# quote-pdf-project

This repository contains the source code for the Salesforce Quote PDF generation project.

## Project Overview

The project includes:
- Apex controller `QuoteController`
- Visualforce page `QuotePDFTemplate`
- Supporting metadata like custom objects and test classes

## Development Flow

### Work Environment
You develop in your **Dev Sandbox**, then deploy changes to **Sandbox 1 (SB1)** for staging verification, and finally deploy to **Production**.

## Git & GitHub Setup

To initialize your local project with Git and connect it to GitHub:

### 1. Initialize Git (if not already initialized)
```bash
git init
```

### 2. Add and commit files
```bash
git add .
git commit -m "Initial commit"
```

### 3. Create a GitHub repo from terminal
```bash
gh repo create quote-pdf-project --public --source=. --remote=origin --push
```

If you see an error like: `Unable to add remote "origin"` – it means the remote already exists.

### 4. Fix the remote origin (if needed)
```bash
git remote set-url origin https://github.com/helencasier/quote-pdf-project.git
```

### 5. Verify the remote
```bash
git remote -v
```

### 6. Push to GitHub
```bash
git push -u origin main
```



# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)
