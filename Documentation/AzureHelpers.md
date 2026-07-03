# AzureHelpers.ps1 Design Guide

## Purpose

`AzureHelpers.ps1` is the centralized helper library for the Azure Migration Framework.

It contains reusable functions that are shared across all deployment modules. The goal is to eliminate duplicated code, improve consistency, and provide a single location for common Azure operations.

Every deployment script should import this file before performing any Azure-related tasks.

```powershell
. "$PSScriptRoot\..\Common\AzureHelpers.ps1"
. "$PSScriptRoot\..\Common\01-Variables.ps1"
```

---

# Design Principles

The helper library follows these principles:

* One place for all reusable helper functions.
* Keep functions generic and reusable.
* Do not place deployment-specific business logic here.
* Add helper functions only when there is a real need.
* Ensure helper functions are idempotent whenever possible.
* Keep functions small, readable, and easy to test.
* Maintain consistent logging and error handling.

---

# Helper Library Structure

```
AzureHelpers.ps1

├── Logging
│   ├── Write-Log
│   └── Write-Step
│
├── Azure Session
│   ├── Test-AzLogin
│   └── Test-Subscription
│
├── Resource Helpers
│   ├── Get-ResourceIfExists
│   └── Invoke-WithRetry
│
├── Validation Helpers
│   ├── Test-ResourceGroupName
│   ├── Test-Location
│   └── Test-ResourceExists
│
└── Future Helpers
    ├── Wait-AzDeployment
    ├── Remove-AzResourceSafe
    ├── Confirm-AzContext
    └── ...
```

---

# Function Categories

## Logging

Responsible for consistent console output.

Examples:

* Write-Log
* Write-Step

---

## Azure Session

Responsible for authentication and Azure context validation.

Examples:

* Test-AzLogin
* Test-Subscription

---

## Resource Helpers

Reusable helper functions for querying or interacting with Azure resources.

Examples:

* Get-ResourceIfExists
* Invoke-WithRetry

---

## Validation Helpers

Reusable validation logic used by multiple deployment modules.

Examples:

* Test-ResourceGroupName
* Test-Location
* Test-ResourceExists

---

## Future Helpers

As the framework grows, additional reusable helper functions can be added here.

Only add a function after it has proven useful in at least one deployment scenario.

---

# Decision Flow

```
Need a new function?
        │
        ▼
Is it reusable?
        │
   Yes ───── No
    │         │
    ▼         ▼
Is it Azure-  Keep it inside
generic?      the deployment
    │          module
Yes │
    ▼
Add to AzureHelpers.ps1
    │
    ▼
Document it here
```

---

# Current Helper Inventory

| Category         | Functions                              |
| ---------------- | -------------------------------------- |
| Logging          | Write-Log, Write-Step                  |
| Azure Session    | Test-AzLogin, Test-Subscription        |
| Resource Helpers | Get-ResourceIfExists, Invoke-WithRetry |
| Validation       | *(To be expanded as needed)*           |

---

# Framework Philosophy

The helper library grows naturally alongside the Azure Migration Framework.

We intentionally avoid creating helper functions "just in case." Every function is introduced only after a genuine need arises during development.

This approach keeps the framework lightweight, maintainable, well-tested, and easy to understand.
