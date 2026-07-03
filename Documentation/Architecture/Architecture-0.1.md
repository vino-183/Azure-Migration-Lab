AzureMigration/
│
├── Deploy.ps1          ✅ Entry point
├── Destroy.ps1         ✅ Cleanup entry point
├── Validate.ps1        ✅ Pre-flight checks
├── Framework.ps1       ✅ Bootstrap
├── README.md
│
├── Common/
│   ├── AzureHelpers.ps1
│   └── 01-Variables.ps1
│
├── Modules/
│   ├── 01-ResourceGroup.ps1
│   ├── 02-VirtualNetwork.ps1
│   ├── ...
│   └── 06-AzureBastion.ps1
│
├── Documentation/
│   ├── AzureHelpers.md
│   └── ...
│
└── Logs/               (future)