# BIOSWHISPER.PS1 - O Telepata de Firmware
# Script PowerShell para acesso direto às variáveis UEFI/BIOS do Windows
# Autor: BIOSWHISPER
# Aviso: Uso por sua conta e risco. Comandos incorretos podem brickar a placa-mãe.

#Requires -RunAsAdministrator
#Requires -Version 5.1

# Importa o módulo principal
$modulePath = Join-Path $PSScriptRoot "BIOSWHISPER-Core.psm1"
if (Test-Path $modulePath) {
    Import-Module $modulePath -Force -ErrorAction Stop
} else {
    Write-Host "Erro: Módulo BIOSWHISPER-Core.psm1 não encontrado em: $modulePath" -ForegroundColor Red
    exit 1
}

function Show-Warning {
    Clear-Host
    Write-Host "================================================" -ForegroundColor Red
    Write-Host "  BIOSWHISPER.PS1 - ACESSO DIRETO À UEFI NVRAM  " -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "VOCÊ ESTÁ PRESTES A LER/ESCREVER NA BIOS DO SEU COMPUTADOR." -ForegroundColor Yellow
    Write-Host "UM COMANDO ERRADO PODE BRICKAR SUA PLACA-MÃE." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Este script:" -ForegroundColor Cyan
    Write-Host "  - Lê variáveis UEFI diretamente do Windows" -ForegroundColor White
    Write-Host "  - Pode modificar configurações de firmware" -ForegroundColor White
    Write-Host "  - Detecta alterações maliciosas no BIOS" -ForegroundColor White
    Write-Host "  - Faz backup completo do NVRAM UEFI" -ForegroundColor White
    Write-Host ""
    Write-Host "Riscos:" -ForegroundColor Red
    Write-Host "  - Alterações incorretas podem tornar o sistema não inicializável" -ForegroundColor White
    Write-Host "  - Modificação de variáveis críticas pode brickar o hardware" -ForegroundColor White
    Write-Host "  - Perda de garantia em alguns casos" -ForegroundColor White
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Red
    Write-Host ""
    
    $confirmation = Read-Host "DIGITE 'EU ENTENDO OS RISCOS' PARA CONTINUAR"
    
    if ($confirmation -ne "EU ENTENDO OS RISCOS") {
        Write-Host "Operação cancelada." -ForegroundColor Red
        exit 1
    }
    
    Write-Host ""
    Write-Host "Continuando..." -ForegroundColor Green
    Write-Host ""
}

# ============================================
# MENU PRINCIPAL
# ============================================

function Show-Menu {
    Clear-Host
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "           BIOSWHISPER.PS1 - MENU PRINCIPAL       " -ForegroundColor Cyan
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[INFORMAÇÃO]" -ForegroundColor White
    Write-Host "1. Listar todas as variáveis UEFI" -ForegroundColor White
    Write-Host "2. Ver informações detalhadas do firmware" -ForegroundColor White
    Write-Host "3. Ver informações de hardware (UUID, serial, BIOS)" -ForegroundColor White
    Write-Host "4. Ver chave de produto Windows (MSDM)" -ForegroundColor White
    Write-Host "5. Listar entradas de boot" -ForegroundColor White
    Write-Host "6. Buscar variáveis de fabricante (senhas)" -ForegroundColor White
    Write-Host ""
    Write-Host "[BACKUP/RESTAURAÇÃO]" -ForegroundColor White
    Write-Host "7. Fazer backup completo das variáveis UEFI" -ForegroundColor White
    Write-Host "8. Restaurar backup de variáveis UEFI" -ForegroundColor White
    Write-Host "9. Comparar estado atual com backup" -ForegroundColor White
    Write-Host "10. Exportar relatório JSON (modo silencioso)" -ForegroundColor White
    Write-Host ""
    Write-Host "[LEITURA/ESCRITA]" -ForegroundColor White
    Write-Host "11. Ler variável UEFI específica" -ForegroundColor White
    Write-Host ""
    Write-Host "[MODO AVANÇADO - PERIGO]" -ForegroundColor Red
    Write-Host "12. Alterar ordem de boot" -ForegroundColor Red
    Write-Host "13. Remover entrada de boot" -ForegroundColor Red
    Write-Host "14. Escrever variável UEFI" -ForegroundColor Red
    Write-Host ""
    Write-Host "0. Sair" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
}

# ============================================
# EXECUÇÃO PRINCIPAL
# ============================================

# Verifica se está rodando como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "Este script requer privilégios de administrador!" -ForegroundColor Red
    Write-Host "Execute novamente como administrador." -ForegroundColor Yellow
    exit 1
}

# Mostra aviso
Show-Warning

# Loop principal
do {
    Show-Menu
    $choice = Read-Host "Escolha uma opção"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "Listando variáveis UEFI..." -ForegroundColor Cyan
            $variables = Get-UEFIVariables
            $variables | Format-Table Name, GUID, GUIDName, Description, Size -AutoSize
            Write-Host ""
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "2" {
            Write-Host ""
            Show-UEFIInfo
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "3" {
            Write-Host ""
            Get-SystemHardwareInfo
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "4" {
            Write-Host ""
            Get-MSDMKey
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "5" {
            Write-Host ""
            Get-BootEntries
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "6" {
            Write-Host ""
            Get-ManufacturerVariables
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "7" {
            Write-Host ""
            $path = Export-UEFIBackup
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "8" {
            Write-Host ""
            $path = Read-Host "Caminho do arquivo de backup"
            Import-UEFIBackup -InputPath $path
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "9" {
            Write-Host ""
            $path = Read-Host "Caminho do arquivo de backup"
            Compare-UEFIState -BackupPath $path
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "10" {
            Write-Host ""
            Export-UEFIJSON
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "11" {
            Write-Host ""
            $name = Read-Host "Nome da variável"
            $guid = Read-Host "GUID (pressione Enter para padrão)"
            
            if ([string]::IsNullOrEmpty($guid)) {
                $guid = "{8BE4DF61-93CA-11D2-AA0D-00E098032B8C}"
            }
            
            $result = Get-UEFIVariable -Name $name -GUID $guid
            
            if ($result.Success) {
                Write-Host "Variável encontrada:" -ForegroundColor Green
                Write-Host "  Nome: $($result.Name)" -ForegroundColor White
                Write-Host "  GUID: $($result.GUID)" -ForegroundColor White
                Write-Host "  Atributos: $($result.Attributes)" -ForegroundColor White
                Write-Host "  Tamanho: $($result.Data.Length) bytes" -ForegroundColor White
                Write-Host "  Dados (hex): $([System.BitConverter]::ToString($result.Data).Replace('-', ' '))" -ForegroundColor White
            } else {
                Write-Host "Erro ao ler variável: $($result.Error)" -ForegroundColor Red
            }
            
            Write-Host ""
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "12" {
            Write-Host ""
            Write-Host "MODO AVANÇADO - Alterar ordem de boot" -ForegroundColor Red
            $orderStr = Read-Host "Nova ordem (separada por vírgulas, ex: 0,1,2)"
            $order = $orderStr -split ',' | ForEach-Object { [int]$_.Trim() }
            Set-BootOrder -NewOrder $order
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "13" {
            Write-Host ""
            Write-Host "MODO AVANÇADO - Remover entrada de boot" -ForegroundColor Red
            $index = Read-Host "Índice da entrada de boot (0-19)"
            Remove-BootEntry -Index $index
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "14" {
            Write-Host ""
            Write-Host "MODO AVANÇADO - Escrever variável UEFI" -ForegroundColor Red
            Write-Host "ATENÇÃO: Isso pode brickar seu sistema!" -ForegroundColor Yellow
            Write-Host ""
            
            $name = Read-Host "Nome da variável"
            $guid = Read-Host "GUID (pressione Enter para padrão)"
            $hexData = Read-Host "Dados em hexadecimal (ex: 01 02 03 FF)"
            
            if ([string]::IsNullOrEmpty($guid)) {
                $guid = "{8BE4DF61-93CA-11D2-AA0D-00E098032B8C}"
            }
            
            $data = $hexData -split ' ' | ForEach-Object { [byte]("0x$_") }
            
            Write-Host ""
            Write-Host "Confirmação tripla necessária!" -ForegroundColor Red
            $response1 = Read-Host "Digite o nome da variável para confirmar"
            $response2 = Read-Host "Digite 'SIM' para confirmar"
            $response3 = Read-Host "Digite 'EU ENTENDO OS RISCOS' para confirmar"
            
            if ($response1 -eq $name -and $response2 -eq "SIM" -and $response3 -eq "EU ENTENDO OS RISCOS") {
                $result = Set-UEFIVariable -Name $name -GUID $guid -Data $data
                
                if ($result.Success) {
                    Write-Host "Variável escrita com sucesso!" -ForegroundColor Green
                } else {
                    Write-Host "Erro ao escrever variável: $($result.Error)" -ForegroundColor Red
                }
            } else {
                Write-Host "Confirmação falhou. Operação cancelada." -ForegroundColor Yellow
            }
            
            Write-Host ""
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
        
        "0" {
            Write-Host ""
            Write-Host "Saindo..." -ForegroundColor Yellow
            exit 0
        }
        
        default {
            Write-Host ""
            Write-Host "Opção inválida!" -ForegroundColor Red
            Write-Host "Pressione qualquer tecla para continuar..."
            $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        }
    }
} while ($choice -ne "0")
