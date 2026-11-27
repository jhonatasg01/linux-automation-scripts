#!/bin/bash
#Atualização completa (APT + Flatpak) e limpeza de sistema para Linux Mint/Ubuntu.

set -euo pipefail

echo "=============================="
echo "      UPDATE LINUX v.1.1      "
echo "=============================="

echo -e "\n>>> [1/4] Atualizando pacotes APT do sistema..."
sudo apt update
sudo apt full-upgrade -y

if command -v flatpak &> /dev/null; then
    echo -e "\n>>> [2/4] Atualizando pacotes Flatpak..."
    flatpak update -y
else
    echo -e "\n>>> [2/4] Flatpak não encontrado. Pulando etapa..."
fi

echo -e "\n>>> [3/4] Iniciando limpeza de pacotes..."
#Limpeza do APT
sudo apt autoremove --purge -y
sudo apt clean

#Limpeza do Flatpak
if command -v flatpak &> /dev/null; then
    flatpak uninstall --unused -y
    flatpak repair --user || true
fi

echo -e "\n>>> [4/4] Limpando logs antigos e cache de miniaturas..."
#Logs de até 7 dias
sudo journalctl --vacuum-time=7d
#Cache de miniaturas
rm -rf ~/.cache/thumbnails/*

echo -e "\n>>> Sistema atualizado e limpo com sucesso!"
