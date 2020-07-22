$resourceTypes = Get-AzPolicyAlias -ListAvailable
$providers = $resourceTypes | Group-Object -Property Namespace

$basePath = "aliases"
if (!(Test-Path -Path $basePath)) {
    New-Item -Name $basePath -ItemType "directory"
}

$toc = "# Azure Policy Aliases`n"
$toc += "This repository contains all available aliases for resource properties. The data is periodically fetched using Get-AzPolicyAlias command provided as part of the Az Module.`n`n"

foreach ($provider in $providers) {
    $resourceTypesWithAliases = $provider.Group | Where-Object { $_.Aliases.Count -gt 0 }
    if ($resourceTypesWithAliases.Count -gt 0) {
        $toc += "## $($provider.Name)`n`n"
        
        $namespacePath = "$($basePath)/$($provider.Name)"
        if (!(Test-Path -Path $namespacePath)) {
            New-Item -Path $basePath -Name $provider.Name -ItemType "directory"
        }

        foreach ($resourceType in $resourceTypesWithAliases) {
            $resourceMarkdown = "# $($resourceType.Namespace)/$($resourceType.ResourceType)`n`n"
            $resourceMarkdown += "| Default Path | Alias |`n|---|---|`n"
            foreach ($alias in $resourceType.Aliases) {
                $resourceMarkdown += "| ``$($alias.DefaultPath)`` | ``$($alias.Name)`` |`n"
            }
            $fileName = $resourceType.ResourceType.Replace("/", "-")
            $filePath = "$($namespacePath)/$($fileName).md"
            $resourceMarkdown | Out-File -FilePath $filePath

            $toc += "- [$($resourceType.Namespace)/$($resourceType.ResourceType)]($filePath)`n"
        }

        $toc += "`n`n"

        $toc | Out-File -FilePath "README.md"
    }
}