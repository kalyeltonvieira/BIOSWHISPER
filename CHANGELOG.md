# Changelog

All notable changes to BIOSWHISPER will be documented in this file.

## [1.0.0] - 2026-06-04

### Added
- Script principal BIOSWHISPER.PS1 com acesso completo a variáveis UEFI/BIOS
- PInvoke declarations para Windows API (CreateFile, DeviceIoControl, GetFirmwareEnvironmentVariableEx, SetFirmwareEnvironmentVariableEx)
- Sistema de segurança com aviso inicial exigindo "EU ENTENDO OS RISCOS"
- Listagem de todas as variáveis UEFI disponíveis
- Backup completo de todas as variáveis UEFI em formato JSON
- Restauração de backups de UEFI
- Detecção de alterações comparando estado atual com backup
- Modo silencioso com exportação JSON para inventário
- Modo avançado com confirmação tripla para escrita de variáveis
- Tradução de GUIDs para nomes legíveis (Dell, Lenovo, HP, ASUS, MSI, Gigabyte, Intel, AMD)
- Detecção de chave de produto Windows (MSDM)
- Extração de informações de hardware (UUID, serial, placa-mãe, BIOS)
- Listagem de entradas de boot com parsing de EFI_LOAD_OPTION
- Remoção de entradas de boot sem reinicialização
- Busca de variáveis de fabricante (incluindo possíveis senhas de supervisor)
- Alteração de ordem de boot via linha de comando
- Escrita de variáveis UEFI arbitrárias
- Menu interativo organizado por categorias

### Scripts Auxiliares
- BIOSWHISPER-Automated.PS1 para uso automatizado sem interação
- BIOSWHISPER-Batch.PS1 para execução em múltiplas máquinas remotas
- servers.txt como template para lista de computadores

### Documentação
- README.md com instruções completas de uso
- LICENSE com disclaimer de responsabilidade
- .gitignore para evitar commit de dados sensíveis

### Features Técnicas
- Acesso direto ao UEFI Runtime Services via API do Windows
- Suporte a múltiplos GUIDs de fabricante
- Parsing de estruturas EFI (EFI_LOAD_OPTION)
- Detecção de Secure Boot status
- Extração de chaves PK, KEK, db, dbx
- Detecção de configurações de overclock
- Identificação de variáveis de senha de supervisor

### Segurança
- Confirmação tripla para operações de escrita
- Aviso inicial obrigatório
- Verificação de privilégios de administrador
- Proteção contra operações não intencionais

## [Future Plans]

### Planned
- [ ] Adicionar suporte para criação de novas entradas de boot
- [ ] Implementar verificação de integridade do firmware
- [ ] Adicionar suporte para variáveis autenticadas (signed variables)
- [ ] Interface gráfica (GUI) opcional
- [ ] Exportação em formatos adicionais (XML, CSV)
- [ ] Comparação entre dois backups
- [ ] Validação de backups antes de restauração
- [ ] Suporte para UEFI variables em sistemas Linux (via WSL)
- [ ] Detecção automática de fabricante e GUIDs específicos
- [ ] Modo de auditoria com log de todas as operações

### Known Limitations
- Requer Windows 7 ou superior
- Requer PowerShell 5.1 ou superior
- Requer privilégios de administrador
- Algumas variáveis podem ser protegidas pelo firmware
- Funcionalidades podem variar entre fabricantes
- Não funciona em sistemas com Legacy BIOS (requer UEFI)
