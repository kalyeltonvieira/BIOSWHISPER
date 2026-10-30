# BIOSWHISPER-Batch.PS1
# Script para executar BIOSWHISPER em múltiplas máquinas remotas
# Uso: .\BIOSWHISPER-Batch.PS1 -ComputerList "servers.txt" -Action Backup

#Requires -Version 5.1

param(
    [Parameter(Mandatory=$true)]
    [string]$ComputerList,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("Backup", "Info", "Hardware", "JSON")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = ".\BatchResults",
    
    [Parameter(Mandatory=$false)]
    [PSCredential]$Credential
)

# Importa o módulo principal
Import-Module $PSScriptRoot\BIOSWHISPER-Core.psm1 -Force

# Cria diretório de saída
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

# Lê lista de computadores
$computers = Get-Content $ComputerList

$results = @()

foreach ($computer in $computers) {
    Write-Host "Processando $computer..." -ForegroundColor Cyan
    
    try {
        # Copia script para máquina remota
        $session = New-PSSession -ComputerName $computer -Credential $Credential -ErrorAction Stop
        
        # Copia o script principal
        Copy-Item -Path "$PSScriptRoot\BIOSWHISPER.PS1" -Destination "C:\Temp\" -ToSession $session -Force
        
        # Executa ação remotamente
        switch ($Action) {
            "Backup" {
                $outputFile = "$OutputDir\${computer}_UEFI_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').uefi"
                $result = Invoke-Command -Session $session -ScriptBlock {
                    param($scriptPath)
                    & $scriptPath -Action Backup -OutputPath "C:\Temp\backup.uefi"
                    Get-Content "C:\Temp\backup.uefi" -Raw
                } -ArgumentList "C:\Temp\BIOSWHISPER.PS1"
                
                $result | Out-File -FilePath $outputFile -Encoding UTF8
            }
            
            "Info" {
                $outputFile = "$OutputDir\${computer}_UEFI_Info_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
                $result = Invoke-Command -Session $session -ScriptBlock {
                    param($scriptPath)
                    & $scriptPath -Action Info
                } -ArgumentList "C:\Temp\BIOSWHISPER.PS1"
                
                $result | Out-File -FilePath $outputFile -Encoding UTF8
            }
            
            "Hardware" {
                $outputFile = "$OutputDir\${computer}_Hardware_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
                $result = Invoke-Command -Session $session -ScriptBlock {
                    param($scriptPath)
                    & $scriptPath -Action Hardware
                } -ArgumentList "C:\Temp\BIOSWHISPER.PS1"
                
                $result | Out-File -FilePath $outputFile -Encoding UTF8
            }
            
            "JSON" {
                $outputFile = "$OutputDir\${computer}_UEFI_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
                $result = Invoke-Command -Session $session -ScriptBlock {
                    param($scriptPath)
                    & $scriptPath -Action JSON -OutputPath "C:\Temp\report.json"
                    Get-Content "C:\Temp\report.json" -Raw
                } -ArgumentList "C:\Temp\BIOSWHISPER.PS1"
                
                $result | Out-File -FilePath $outputFile -Encoding UTF8
            }
        }
        
        $results += [PSCustomObject]@{
            Computer = $computer
            Status = "Success"
            OutputFile = $outputFile
            Error = $null
        }
        
        Write-Host "✓ $computer concluído" -ForegroundColor Green
        
        # Limpa arquivos temporários
        Invoke-Command -Session $session -ScriptBlock {
            Remove-Item "C:\Temp\BIOSWHISPER.PS1" -Force -ErrorAction SilentlyContinue
            Remove-Item "C:\Temp\backup.uefi" -Force -ErrorAction SilentlyContinue
            Remove-Item "C:\Temp\report.json" -Force -ErrorAction SilentlyContinue
        }
        
        Remove-PSSession $session
        
    } catch {
        $results += [PSCustomObject]@{
            Computer = $computer
            Status = "Failed"
            OutputFile = $null
            Error = $_.Exception.Message
        }
        
        Write-Host "✗ $computer falhou: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Gera relatório final
$reportFile = "$OutputDir\BatchReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$results | Export-Csv -Path $reportFile -NoTypeInformation

Write-Host ""
Write-Host "=== RELATÓRIO FINAL ===" -ForegroundColor Cyan
$results | Format-Table Computer, Status, OutputFile, Error -AutoSize

Write-Host ""
Write-Host "Relatório salvo em: $reportFile" -ForegroundColor Green
Write-Host "Total de computadores: $($computers.Count)" -ForegroundColor White
Write-Host "Sucessos: $(($results | Where-Object { $_.Status -eq 'Success' }).Count)" -ForegroundColor Green
Write-Host "Falhas: $(($results | Where-Object { $_.Status -eq 'Failed' }).Count)" -ForegroundColor Red
