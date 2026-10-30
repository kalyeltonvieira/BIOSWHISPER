# Check-Prerequisites.PS1
# Verifica se o sistema atende todos os pré-requisitos para usar BIOSWHISPER

#Requires -Version 5.1

Write-Host "=== VERIFICAÇÃO DE PRÉ-REQUISITOS BIOSWHISPER ===" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# 1. Verifica versão do PowerShell
Write-Host "[1/8] Verificando versão do PowerShell..." -ForegroundColor Yellow
$psVersion = $PSVersionTable.PSVersion
Write-Host "  Versão: $psVersion" -ForegroundColor White

if ($psVersion.Major -ge 5) {
    Write-Host "  ✓ PowerShell 5.1 ou superior detectado" -ForegroundColor Green
} else {
    Write-Host "  ✗ PowerShell 5.1 ou superior requerido" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# 2. Verifica se está rodando como administrador
Write-Host "[2/8] Verificando privilégios de administrador..." -ForegroundColor Yellow
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if ($isAdmin) {
    Write-Host "  ✓ Executando como administrador" -ForegroundColor Green
} else {
    Write-Host "  ✗ Requer execução como administrador" -ForegroundColor Red
    Write-Host "  Execute novamente como: Executar como Administrador" -ForegroundColor Yellow
    $allPassed = $false
}
Write-Host ""

# 3. Verifica versão do Windows
Write-Host "[3/8] Verificando versão do Windows..." -ForegroundColor Yellow
$osVersion = [System.Environment]::OSVersion.Version
$osName = (Get-CimInstance Win32_OperatingSystem).Caption
Write-Host "  Sistema: $osName" -ForegroundColor White
Write-Host "  Versão: $osVersion" -ForegroundColor White

if ($osVersion.Major -ge 6) {
    Write-Host "  ✓ Windows 7 ou superior detectado" -ForegroundColor Green
} else {
    Write-Host "  ✗ Windows 7 ou superior requerido" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# 4. Verifica se o sistema usa UEFI
Write-Host "[4/8] Verificando modo de boot (UEFI vs Legacy)..." -ForegroundColor Yellow
try {
    $firmwareType = (Get-ComputerInfo).BiosFirmwareType
    Write-Host "  Tipo de Firmware: $firmwareType" -ForegroundColor White
    
    if ($firmwareType -eq "Uefi") {
        Write-Host "  ✓ Sistema usando UEFI" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Sistema não está usando UEFI (Legacy BIOS detectado)" -ForegroundColor Yellow
        Write-Host "  BIOSWHISPER pode ter funcionalidades limitadas" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠ Não foi possível determinar o tipo de firmware" -ForegroundColor Yellow
    Write-Host "  Tentando método alternativo..." -ForegroundColor Yellow
    
    # Método alternativo: verifica se existe a partição EFI
    $efiPartition = Get-Partition | Where-Object { $_.GptType -eq "{C12A7328-F81F-11D2-BA4B-00A0C93EC93B}" }
    if ($efiPartition) {
        Write-Host "  ✓ Partição EFI detectada (sistema UEFI)" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Partição EFI não detectada (possível Legacy BIOS)" -ForegroundColor Yellow
    }
}
Write-Host ""

# 5. Verifica se o script principal existe
Write-Host "[5/8] Verificando arquivos do BIOSWHISPER..." -ForegroundColor Yellow
$scriptPath = "$PSScriptRoot\BIOSWHISPER.PS1"

if (Test-Path $scriptPath) {
    Write-Host "  ✓ BIOSWHISPER.PS1 encontrado" -ForegroundColor Green
} else {
    Write-Host "  ✗ BIOSWHISPER.PS1 não encontrado" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# 6. Verifica se as APIs do Windows estão disponíveis
Write-Host "[6/8] Verificando APIs do Windows..." -ForegroundColor Yellow
try {
    Add-Type -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
public static extern bool GetFirmwareEnvironmentVariableEx(
    string lpName,
    string lpGuid,
    [Out] byte[] pBuffer,
    uint nSize,
    out uint pdwAttributes);
"@ -Name "TestAPI" -Namespace "BIOSWHISPER" -ErrorAction Stop
    
    Write-Host "  ✓ APIs do Windows disponíveis" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Não foi possível carregar APIs do Windows" -ForegroundColor Red
    $allPassed = $false
}
Write-Host ""

# 7. Verifica se consegue ler uma variável UEFI de teste
Write-Host "[7/8] Testando leitura de variável UEFI..." -ForegroundColor Yellow
try {
    $buffer = [byte[]]::new(4)
    $attributes = 0u
    
    # Tenta ler uma variável que geralmente existe
    $result = [BIOSWHISPER.TestAPI]::GetFirmwareEnvironmentVariableEx(
        "BootOrder",
        "{8BE4DF61-93CA-11D2-AA0D-00E098032B8C}",
        $buffer,
        $buffer.Length,
        [ref]$attributes
    )
    
    if ($result -or [System.Runtime.InteropServices.Marshal]::GetLastWin32Error() -eq 203) {
        # 203 = ERROR_ENVVAR_NOT_FOUND (o que é OK, significa que a API funciona)
        Write-Host "  ✓ Acesso a variáveis UEFI funcionando" -ForegroundColor Green
    } else {
        $errorCode = [System.Runtime.InteropServices.Marshal]::GetLastWin32Error()
        Write-Host "  ⚠ Erro ao testar acesso: código $errorCode" -ForegroundColor Yellow
        Write-Host "  Isso pode ser normal dependendo da configuração do sistema" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠ Não foi possível testar acesso a variáveis UEFI" -ForegroundColor Yellow
    Write-Host "  $_" -ForegroundColor Gray
}
Write-Host ""

# 8. Verifica espaço em disco para backups
Write-Host "[8/8] Verificando espaço em disco..." -ForegroundColor Yellow
$drive = (Get-Location).Drive.Name
$freeSpace = (Get-PSDrive $drive).Free / 1MB
Write-Host "  Drive $drive`: $([math]::Round($freeSpace, 2)) MB livres" -ForegroundColor White

if ($freeSpace -gt 10) {
    Write-Host "  ✓ Espaço suficiente para backups" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Espaço em disco baixo (< 10 MB)" -ForegroundColor Yellow
}
Write-Host ""

# Resumo
Write-Host "=== RESUMO ===" -ForegroundColor Cyan
Write-Host ""

if ($allPassed) {
    Write-Host "✓ Todos os pré-requisitos críticos foram atendidos!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Você pode executar o BIOSWHISPER:" -ForegroundColor White
    Write-Host "  .\BIOSWHISPER.PS1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ou usar o modo automatizado:" -ForegroundColor White
    Write-Host "  .\BIOSWHISPER-Automated.PS1 -Action Backup" -ForegroundColor Cyan
} else {
    Write-Host "✗ Alguns pré-requisitos críticos não foram atendidos" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, resolva os problemas acima antes de usar o BIOSWHISPER." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Pressione qualquer tecla para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
