#!/bin/bash
#Backup remoto de arquivos/pastas de uma VPS via rsync e SSH.

set -euo pipefail

echo "=================================="
echo "      BACKUP DE ARQUIVOS VPS      "
echo "              v.1.1               "
echo "=================================="

#Carrega as configurações se o arquivo config.env existir
if [[ -f "./config.env" ]]; then
    source "./config.env"
    echo "[INFO] Configurações carregadas de config.env"
fi

[[ -z "${CHAVE_SSH:-}" ]] && read -rp "Local da chave SSH (ex: ~/.ssh/chave.key): " CHAVE_SSH
CHAVE_SSH="${CHAVE_SSH/#\~/$HOME}"

if [[ ! -f "$CHAVE_SSH" ]]; then
    echo "[ERRO] Chave SSH não encontrada em: $CHAVE_SSH"
    exit 1
fi

[[ -z "${USUARIO:-}" ]] && read -rp "Nome do usuário Linux na VPS: " USUARIO
[[ -z "${IP_VPS:-}" ]] && read -rp "IP da máquina VPS: " IP_VPS
[[ -z "${PATH_LOCAL:-}" ]] && read -rp "Pasta local de destino (ex: /mnt/backup): " PATH_LOCAL
[[ -z "${PATH_NUVEM:-}" ]] && read -rp "Pasta remota na VPS (ex: /var/lib/jellyfin): " PATH_NUVEM

#Garantindo que os caminhos terminem com /
PATH_NUVEM="${PATH_NUVEM%/}/"
PATH_LOCAL="${PATH_LOCAL%/}/"

#Criando pasta local caso não exista
mkdir -p "$PATH_LOCAL"

echo -e "\nTipo de transferência:"
echo "1 - Arquivo único"
echo "2 - Uma ou mais pastas/arquivos separados por vírgula"
read -rp "Selecione uma opção: " tipo

origens=()

case "$tipo" in
    1)
        read -rp "Informe o nome do arquivo: " arquivo
        arquivo=$(echo "$arquivo" | sed -e "s/^['\"]//" -e "s/['\"]$//")
        origens+=("${USUARIO}@${IP_VPS}:${PATH_NUVEM}${arquivo}")
        ;;
    2)
        read -rp "Informe os nomes separados por VÍRGULA (ex: Filmes, Series): " entrada
        IFS=',' read -ra itens <<< "$entrada"

        for item in "${itens[@]}"; do
            #removendo espaços nas pontas e aspas acidentais
            item=$(echo "$item" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e "s/^['\"]//" -e "s/['\"]$//")
            [[ -n "$item" ]] && origens+=("${USUARIO}@${IP_VPS}:${PATH_NUVEM}${item}")
        done
        ;;
    *)
        echo "[ERRO] Opção inválida. Saindo..."
        exit 1
        ;;
esac

if [[ ${#origens[@]} -eq 0 ]]; then
    echo "[ERRO] Nenhuma origem válida informada."
    exit 1
fi

echo -e "\n>>> Iniciando transferência com rsync..."
# -a: modo arquivo (mantém permissões e pastas)
# -v: detalhado
# -h: tamanhos legíveis (GB, MB)
# -s: envia caracteres nos nomes dos arquivos ou caminhos de forma segura
# --partial: mantém arquivos incompletos se a rede cair
# --progress: mostra barra de progresso e velocidade
rsync -avhs --partial --progress -e "ssh -i \"$CHAVE_SSH\"" "${origens[@]}" "$PATH_LOCAL"

echo -e "\n>>> Backup concluído com sucesso!"
