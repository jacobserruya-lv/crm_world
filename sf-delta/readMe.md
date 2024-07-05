# Deployment Script Documentation

## Overview

This script is designed to automate the process of generating a `package.xml` file and copying modified files to a delta directory for Salesforce metadata deployment. The script identifies modified files, determines their metadata type, and organizes them into a deployable package.
We use git diff  : git diff --name-only origin/${baseBranch}..HEAD

## Metadata Types

The following is a list of metadata types that the script can detect and deploy based on the file extensions and paths. These types are derived from common Salesforce metadata types.

### Apex Metadata
- **ApexClass**: `.cls`
- **ApexTrigger**: `.trigger`
- **ApexPage**: `.page`

### Custom Object Metadata
- **CustomObject**: `.object`
- **CustomField**: `.field`
- **ValidationRule**: `.validationRule`
- **FieldSet**: `.fieldSet`
- **ListView**: `.listView`
- **CompactLayout**: `.compactLayout`

### Lightning Metadata
- **LightningComponentBundle**: Located in the `lwc` directory.

### Aura Metadata
- **AuraDefinitionBundle**: Located in the `aura` directory.

### Static Resources
- **StaticResource**: Located in the `staticresources` directory, with `.resource` suffix.

### Generic Metadata
- **GenericMetadata**: `.xml` (specific component type is determined by parsing the XML file).

## Excluded Metadata Types

The script excludes certain metadata types from deployment:

- **CustomLabel**
- **CustomMetadata**
- **Certificates**
- **Profiles**
- **SharingRules**
- **Queues**
- **AuthProvider**
- **CallCenter**
- **NamedCredential**
- **ConnectedApp**
- **CSPTrustedApp**

### Note on Excluded Metadata

For metadata types such as `AuthProvider`, `CallCenter`, `NamedCredential`, `ConnectedApp`, and `TrustedApp`, the script can be evolved to dynamically deploy according to the environment. This feature is not currently implemented but is a potential enhancement.

## Usage

1. **Identify Modified Files**: The script identifies files that have been modified in comparison to a specified base branch.
2. **Determine Component Details**: For each modified file, the script determines the component type and name based on the file extension and path.
3. **Generate Delta Directory**: The script copies the modified files and their associated metadata files to a delta directory, preserving the directory structure.
4. **Generate `package.xml`**: The script generates a `package.xml` file that lists all modified components, structured for deployment.

This will generate a `package.xml` in the `delta/main/default` directory and copy the modified files to the same location.

## Example Command

Here's an example of how you might run the script:

```bash
node sf-delta/index.js --projectPath force-app --baseBranch main
