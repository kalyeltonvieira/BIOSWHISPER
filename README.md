# BIOSWHISPER.PS1 - O Telepata de Firmware

Um script PowerShell que lê e escreve diretamente nas variáveis UEFI/BIOS do computador sem reiniciar, sem entrar na tela azul da BIOS, sem flash tool, sem nada. Direto do Windows. Com PowerShell puro.

## ⚠️ AVISO IMPORTANTE

**Este script acessa o nível mais baixo do seu computador - abaixo do sistema operacional.**

**UM COMANDO ERRADO PODE BRICKAR SUA PLACA-MÃE.**

- Alterações incorretas podem tornar o sistema não inicializável
- Modificação de variáveis críticas pode brickar o hardware
- Perda de garantia em alguns casos
- Use por sua conta e risco

## 🚀 Como Usar

### Requisitos

- Windows 7 ou superior
- PowerShell 5.1 ou superior
- Privilégios de Administrador (obrigatório)
- Sistema com UEFI (não Legacy BIOS)

### Verificação de Pré-requisitos

Antes de usar, execute o script de verificação:

```powershell
# Abra o PowerShell como Administrador
cd d:\BIOSWHISPER
.\Check-Prerequisites.PS1
```

Este script verificará:
- Versão do PowerShell
- Privilégios de administrador
- Versão do Windows
- Modo de boot (UEFI vs Legacy)
- Disponibilidade das APIs do Windows
- Espaço em disco

### Execução Interativa

```powershell
# Abra o PowerShell como Administrador
cd d:\BIOSWHISPER
.\BIOSWHISPER.PS1
```

Na primeira execução, você precisará digitar: `EU ENTENDO OS RISCOS`

### Execução Automatizada

Para uso em scripts ou agendamentos:

```powershell
# Backup automatizado
.\BIOSWHISPER-Automated.PS1 -Action Backup -OutputPath "C:\Backups\UEFI.uefi"

# Relatório JSON
.\BIOSWHISPER-Automated.PS1 -Action JSON -OutputPath "C:\Reports\UEFI.json"

# Informações de hardware
.\BIOSWHISPER-Automated.PS1 -Action Hardware
```

### Execução em Múltiplas Máquinas

Para administradores de TI que precisam gerenciar múltiplos servidores:

```powershell
# 1. Crie uma lista de computadores em servers.txt
# 2. Execute o script batch
.\BIOSWHISPER-Batch.PS1 -ComputerList "servers.txt" -Action Backup -OutputDir ".\BatchResults"
```

### Configuração

O arquivo `BIOSWHISPER-Config.json` pode ser usado para personalizar:
- Caminhos padrão de backup e relatórios
- Configurações de segurança
- GUIDs personalizados
- Variáveis de fabricante específicas

## � Estrutura do Projeto

```
BIOSWHISPER/
├── BIOSWHISPER.PS1              # Script principal (menu interativo)
├── BIOSWHISPER-Core.psm1        # Módulo principal com funções UEFI
├── BIOSWHISPER-Automated.PS1    # Script para uso automatizado
├── BIOSWHISPER-Batch.PS1        # Script para múltiplas máquinas
├── Check-Prerequisites.PS1      # Verificação de pré-requisitos
├── BIOSWHISPER-Config.json      # Arquivo de configuração
├── servers.txt                  # Template de lista de servidores
├── README.md                    # Documentação
├── LICENSE                      # Licença MIT
├── CHANGELOG.md                 # Histórico de versões
└── .gitignore                   # Arquivos ignorados pelo Git
```

### Arquivos Principais

- **BIOSWHISPER.PS1**: Script interativo com menu para todas as operações
- **BIOSWHISPER-Core.psm1**: Módulo PowerShell contendo todas as funções UEFI (pode ser importado por outros scripts)
- **BIOSWHISPER-Automated.PS1**: Script para uso automatizado sem interação
- **BIOSWHISPER-Batch.PS1**: Script para executar operações em múltiplas máquinas remotas

## �� Menu de Opções

### [INFORMAÇÃO]

**1. Listar todas as variáveis UEFI**
- Lista todas as variáveis UEFI disponíveis no sistema
- Mostra GUID, nome, descrição e tamanho de cada variável

**2. Ver informações detalhadas do firmware**
- Exibe informações completas sobre o firmware UEFI
- Mostra ordem de boot atual
- Status do Secure Boot
- Timeout de boot
- Total de variáveis por GUID

**3. Ver informações de hardware (UUID, serial, BIOS)**
- UUID do sistema
- Número de série
- Fabricante e modelo da placa-mãe
- Versão da placa-mãe
- Versão da BIOS
- Data de compilação da BIOS
- Fabricante da BIOS

**4. Ver chave de produto Windows (MSDM)**
- Tenta extrair a chave de produto Windows da tabela MSDM
- Usa método alternativo via WMI se MSDM não estiver disponível
- Mostra a chave OEM em formato XXXXX-XXXXX-XXXXX-XXXXX-XXXXX

**5. Listar entradas de boot**
- Lista todas as entradas de boot (Boot0000 a Boot0019)
- Mostra descrição, atributos, status ativo e tamanho
- Útil para gerenciar dual boot sem reiniciar

**6. Buscar variáveis de fabricante (senhas)**
- Busca variáveis específicas de Dell, Lenovo, HP, ASUS, MSI, Gigabyte
- Procura por senhas de supervisor (AdminPassword, UserPassword, etc.)
- Procura configurações de overclock (CPU_OC, Memory_OC, Voltage)
- **ATENÇÃO:** Pode revelar senhas em plain text ou ofuscadas

### [BACKUP/RESTAURAÇÃO]

**7. Fazer backup completo das variáveis UEFI**
- Exporta TODAS as variáveis UEFI para um arquivo .UEFI (JSON)
- Inclui GUID, nome, atributos e dados em Base64
- Nome do arquivo: `UEFI_Backup_YYYYMMDD_HHmmss.uefi`
- Isso é algo que nem software de R$1000 faz

**8. Restaurar backup de variáveis UEFI**
- Restaura um backup anterior
- Requer confirmação antes de sobrescrever
- Mostra progresso de cada variável restaurada

**9. Comparar estado atual com backup**
- Compara o estado atual com um backup anterior
- Detecta variáveis alteradas, novas ou removidas
- Útil para detectar bootkits e rootkits de firmware
- Malware que sobrevive a formatação pode ser detectado aqui

**10. Exportar relatório JSON (modo silencioso)**
- Gera relatório completo em JSON sem alterar nada
- Inclui todas as variáveis com dados em hex
- Útil para inventário de hardware sem instalar agente
- Pode ser usado em scripts automatizados

### [LEITURA/ESCRITA]

**11. Ler variável UEFI específica**
- Lê uma variável específica por nome e GUID
- Mostra todos os detalhes: nome, GUID, atributos, tamanho, dados hex
- Útil para análise forense

### [MODO AVANÇADO - PERIGO]

**12. Alterar ordem de boot**
- Altera a ordem de boot via linha de comando
- Não requer reinicialização
- Requer confirmação antes de executar
- Formato: `0,1,2` (índices das entradas de boot)

**13. Remover entrada de boot**
- Remove uma entrada de boot específica
- Útil para limpar entradas de boot antigas ou corrompidas
- Requer confirmação antes de executar
- **PERIGO:** Pode afetar a capacidade de boot do sistema

**14. Escrever variável UEFI**
- Escreve qualquer variável UEFI com dados personalizados
- Reiser confirmação tripla:
  1. Digite o nome da variável
  2. Digite 'SIM'
  3. Digite 'EU ENTENDO OS RISCOS'
- **PERIGO MÁXIMO:** Pode brickar o sistema se usado incorretamente
- Formato dos dados: hexadecimal separado por espaços (ex: `01 02 03 FF`)

## 🔬 Como Funciona

### Tecnologia

O Windows expõe a interface UEFI Runtime Services através do driver `.UEFI`. PowerShell pode acessar esse dispositivo via chamadas .NET para:

- **CreateFile** - Abre handle para o runtime UEFI
- **DeviceIoControl** - Envia comandos UEFI
- **GetFirmwareEnvironmentVariableEx** - Lê variáveis UEFI
- **SetFirmwareEnvironmentVariableEx** - Escreve variáveis UEFI

### Estrutura das Variáveis UEFI

Cada variável UEFI é identificada por:
- **GUID** - Define o namespace (ex: `{8BE4DF61-93CA-11D2-AA0D-00E098032B8C}` para variáveis globais)
- **Nome** - Nome Unicode da variável (ex: `BootOrder`, `SecureBoot`)
- **Atributos** - Flags de acesso (NON_VOLATILE, BOOTSERVICE_ACCESS, RUNTIME_ACCESS)
- **Dados** - Conteúdo binário da variável

### GUIDs Conhecidos

| GUID | Namespace |
|------|-----------|
| `{8BE4DF61-93CA-11D2-AA0D-00E098032B8C}` | Global Variable |
| `{7214CBE2-06A8-4B3E-9A2F-5A2F5E2A7B3C}` | Dell |
| `{F9D6E3A2-4B3C-9A2F-5A2F5E2A7B3C}` | Lenovo |
| `{8F8D4B3C-4B3C-9A2F-5A2F5E2A7B3C}` | HP |
| `{E7B5C3A2-4B3C-9A2F-5A2F5E2A7B3C}` | ASUS |
| `{C8D6E3A2-4B3C-9A2F-5A2F5E2A7B3C}` | MSI |
| `{D9E7F4A3-4B3C-9A2F-5A2F5E2A7B3C}` | Gigabyte |
| `{77FA9ABD-0359-4D32-BD60-28F4E78F784B}` | Secure Boot |

## 📊 Exemplos de Uso

### Backup Antes de Modificações

```powershell
# 1. Faça backup antes de qualquer modificação
.\BIOSWHISPER.PS1
# Escolha opção 7

# 2. Modifique o que precisa
# Escolha opção 12 (alterar boot order)

# 3. Se algo der errado, restaure
# Escolha opção 8
```

### Detectar Alterações Maliciosas

```powershell
# 1. Faça backup baseline
.\BIOSWHISPER.PS1
# Escolha opção 7

# 2. Após algum tempo, compare
.\BIOSWHISPER.PS1
# Escolha opção 9
# Informe o caminho do backup

# 3. Analise as alterações
# Variáveis alteradas podem indicar infecção por bootkit
```

### Inventário de Hardware (Silencioso)

```powershell
# Para uso em scripts automatizados
.\BIOSWHISPER.PS1
# Escolha opção 10

# O arquivo JSON pode ser processado por outros scripts
# Exemplo em PowerShell:
$report = Get-Content .\UEFI_Report_*.json | ConvertFrom-Json
$report.Variables | Where-Object { $_.Name -eq "BootOrder" }
```

### Dual Boot sem Reiniciar

```powershell
# 1. Liste as entradas de boot
.\BIOSWHISPER.PS1
# Escolha opção 5

# 2. Anote os índices (ex: Windows = 0, Linux = 1)

# 3. Altere a ordem de boot
.\BIOSWHISPER.PS1
# Escolha opção 12
# Digite: 1,0 (para bootar Linux primeiro)
```

## 🔒 Segurança

### O que o script NÃO faz

- Não instala drivers
- Não modifica o kernel do Windows
- Não requer reinicialização
- Não deixa rastros no sistema de arquivos (exceto backups/relatórios)
- Não se conecta à internet

### O que o script FAZ

- Lê variáveis UEFI via API do Windows
- Escreve variáveis UEFI via API do Windows
- Faz backup/restauração do NVRAM UEFI
- Detecta alterações no firmware

### Boas Práticas

1. **Sempre faça backup antes de modificar**
2. **Nunca modifique variáveis que você não entende**
3. **Teste em ambiente de teste antes de produção**
4. **Mantenha o backup em local seguro**
5. **Use o modo silencioso (opção 10) para leitura apenas**

## 🐛 Troubleshooting

### "Este script requer privilégios de administrador"

```powershell
# Abra PowerShell como Administrador
# Clique direito no ícone do PowerShell -> Executar como Administrador
```

### "Variável não encontrada"

- A variável pode não existir no seu sistema
- Tente um GUID diferente
- Alguns fabricantes usam GUIDs proprietários

### "Erro ao escrever variável"

- A variável pode ser protegida pelo firmware
- O Secure Boot pode bloquear escrita
- A variável pode ser read-only

### O script não funciona

- Verifique se está usando UEFI (não Legacy BIOS)
- Verifique se o Windows está instalado em modo UEFI
- Algumas funcionalidades podem não estar disponíveis em sistemas mais antigos

## 📚 Referências

- [UEFI Specification](https://uefi.org/specifications)
- [Microsoft Firmware Environment Variables](https://docs.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-getfirmwareenvironmentvariableexa)
- [UEFI Runtime Services](https://uefi.org/specifications/UEFI/2.10)

## 📄 Licença

Este script é fornecido "como está", sem garantias de qualquer tipo. O uso é por sua conta e risco.

## 👨‍💻 Autor

BIOSWHISPER - O Telepata de Firmware

---

**Lembre-se: Com grande poder vem grande responsabilidade.**
