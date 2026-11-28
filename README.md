# Linux Automation Scripts

Coleção de scripts em **Bash** desenvolvidos para automatizar rotinas de manutenção de sistemas baseados em Debian/Ubuntu (como Linux Mint) e gerenciamento de backups remotos via SSH/Rsync.

---

## Estrutura do Repositório

```text
linux-automation-scripts/
├── .gitignore
├── README.md
├── backup-vps/
│   ├── backup-vps.sh
│   └── config.env.example
└── system-maintenance/
    └── update-linux.sh
```

---

## Instalação

Clone o repositório para a sua máquina local e acesse o diretório do projeto:

```bash
git clone https://github.com
cd linux-automation-scripts
```

---

## Scripts Disponíveis

### 1. Backup Remoto de VPS (`backup-vps/backup-vps.sh`)
Automação para transferir arquivos grandes ou múltiplos diretórios de um servidor remoto (como mídias do Jellyfin) para a máquina local utilizando `rsync` sobre SSH.

**Principais funcionalidades:**
*   **Configuração híbrida:** Permite salvar credenciais e caminhos frequentes em um arquivo `config.env` ou preencher interativamente durante a execução.
*   **Transferência resiliente:** Utiliza as flags `--partial` e `--progress` do `rsync` para retomar downloads interrompidos caso a conexão oscile.
*   **Múltiplos alvos:** Suporta o download de um arquivo único ou de várias pastas simultaneamente separadas por vírgula.

#### Como configurar e usar:
1. Acesse a pasta do script e crie seu arquivo de configuração a partir do exemplo:
   ```bash
   cd backup-vps
   cp config.env.example config.env
   ```
2. *(Opcional)* Edite o arquivo `config.env` com os dados do seu servidor. Campos deixados em branco serão solicitados no terminal.
3. Certifique-se de que sua chave SSH pertence ao seu usuário e possui a permissão correta:
   ```bash
   chmod 600 /caminho/da/sua/chave.key
   ```
4. Dê permissão de execução e inicie o script:
   ```bash
   chmod +x backup-vps.sh
   ./backup-vps.sh
   ```

---

### 2. Atualização e Limpeza do Sistema (`system-maintenance/update-linux.sh`)
Script de manutenção preventiva para manter o sistema operacional atualizado e liberar espaço em disco automaticamente.

**O que ele executa:**
1. Atualiza os repositórios e pacotes nativos via `apt` (`update` e `full-upgrade`).
2. Verifica se o `flatpak` está instalado e atualiza todos os aplicativos.
3. Remove dependências órfãs (`autoremove --purge`), limpa o cache do APT (`clean`) e remove runtimes não utilizados do Flatpak.
4. Limpa logs antigos do sistema (`journalctl` acima de 7 dias) e o cache de miniaturas do usuário.

#### Como usar:
```bash
cd system-maintenance
chmod +x update-linux.sh
./update-linux.sh
```

---

## Pré-requisitos

*   Sistema operacional Linux (testado no **Linux Mint** e **Ubuntu**).
*   Pacotes necessários: `bash`, `rsync`, `openssh-client` e `flatpak` *(opcional)*.
*   Privilégios `sudo` para tarefas de atualização e limpeza de sistema.
* Chave SSH privada configurada com permissão `600` e pertencente ao usuário atual.

---

## Boas Práticas Aplicadas

*   Uso de `set -euo pipefail` para tratamento seguro de erros e interrupção imediata em caso de falhas.
*   Isolamento de dados sensíveis (IPs, usuários e caminhos de chaves SSH) através do `.gitignore`.
*   Validação de entradas e manipulação segura de arrays e strings em Bash.
