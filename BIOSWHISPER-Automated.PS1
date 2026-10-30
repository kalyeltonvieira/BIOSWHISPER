# BIOSWHISPER-Automated.PS1
# Script de exemplo para uso automatizado do BIOSWHISPER
# Uso: .\BIOSWHISPER-Automated.PS1 -Action Backup -OutputPath "C:\Backups\UEFI.uefi"

#Requires -RunAsAdministrator
#Requires -Version 5.1

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Backup", "Restore", "Compare", "Info", "Hardware", "MSDM", "BootEntries", "Manufacturer", "JSON")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath,
    
    [Parameter(Mandatory=$false)]
    [string]$BackupPath,
    
    [Parameter(Mandatory=$false)]
    [switch]$Force
)

# Importa o módulo principal
Import-Module $PSScriptRoot\BIOSWHISPER-Core.psm1 -Force

switch ($Action) {
    "Backup" {
        if ([string]::IsNullOrEmpty($OutputPath)) {
            $OutputPath = ".\UEFI_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').uefi"
        }
        $path = Export-UEFIBackup -OutputPath $OutputPath
        Write-Host "Backup salvo em: $path" -ForegroundColor Green
    }
    
    "Restore" {
        if ([string]::IsNullOrEmpty($BackupPath)) {
            Write-Host "Erro: -BackupPath é obrigatório para restore" -ForegroundColor Red
            exit 1
        }
        
        if (-not $Force) {
            Write-Host "Erro: Use -Force para confirmar restore automatizado" -ForegroundColor Red
            exit 1
        }
        
        Import-UEFIBackup -InputPath $BackupPath -Confirm:$false
    }
    
    "Compare" {
        if ([string]::IsNullOrEmpty($BackupPath)) {
            Write-Host "Erro: -BackupPath é obrigatório para comparação" -ForegroundColor Red
            exit 1
        }
        
        $changes = Compare-UEFIState -BackupPath $BackupPath
        
        # Exporta alterações para CSV se houver
        if ($changes.Count -gt 0) {
            $changes | Export-Csv -Path ".\UEFI_Changes_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation
            Write-Host "Alterações exportadas para CSV" -ForegroundColor Green
        }
    }
    
    "Info" {
        Show-UEFIInfo
    }
    
    "Hardware" {
        Get-SystemHardwareInfo
    }
    
    "MSDM" {
        Get-MSDMKey
    }
    
    "BootEntries" {
        Get-BootEntries
    }
    
    "Manufacturer" {
        Get-ManufacturerVariables
    }
    
    "JSON" {
        if ([string]::IsNullOrEmpty($OutputPath)) {
            $OutputPath = ".\UEFI_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
        }
        $path = Export-UEFIJSON -OutputPath $OutputPath
        Write-Host "Relatório salvo em: $path" -ForegroundColor Green
    }
    
    default {
        Write-Host "Ação inválida: $Action" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Operação concluída." -ForegroundColor Green
