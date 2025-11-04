#!/usr/bin/env bash
#
# ==========================================================
#  clean_file_history.sh
#  Rimuove tutta la cronologia di un file da un repository Git
#  e forza l'aggiornamento sul remoto GitHub.
#
#  Autore: vitmil
#  Ultima modifica: 2025-11-04
# ==========================================================

set -e

# --- Funzione di log colorato ---
log() { echo -e "\033[1;32m[INFO]\033[0m $1"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m $1"; }
err()  { echo -e "\033[1;31m[ERR]\033[0m  $1"; }

# --- Controllo prerequisiti ---
if ! command -v git &>/dev/null; then
  err "Git non è installato. Interrompo."
  exit 1
fi

if ! command -v git-filter-repo &>/dev/null; then
  warn "git-filter-repo non trovato. Lo installo ora (richiede sudo)."
  if command -v apt &>/dev/null; then
    sudo apt install -y git-filter-repo
  else
    pip install git-filter-repo
  fi
fi

# --- Parametri richiesti ---
if [[ -z "$1" ]]; then
  err "Uso: $0 <nome_file> [url_repo]"
  echo "Esempio: $0 setup-global-gitignore.sh https://github.com/vitmil/git_scripts.git"
  exit 1
fi

TARGET_FILE="$1"
REPO_URL="${2:-}"

# --- Conferma utente ---
echo
warn "ATTENZIONE: questa operazione riscriverà l'intera history del repository!"
read -rp "Vuoi procedere con la rimozione del file '$TARGET_FILE'? (s/N): " CONFIRM
[[ "$CONFIRM" =~ ^[sS]$ ]] || { echo "Operazione annullata."; exit 0; }

# --- Esecuzione della pulizia ---
log "Rimozione del file '$TARGET_FILE' da tutta la cronologia..."
git filter-repo --path "$TARGET_FILE" --invert-paths

# --- Pulizia dei riferimenti interni ---
log "Pulizia dei riferimenti interni Git..."
rm -rf .git/refs/original/ || true
git reflog expire --expire=now --all || true
git gc --prune=now --aggressive || true

# --- Gestione del remoto ---
if ! git remote -v | grep -q "origin"; then
  if [[ -z "$REPO_URL" ]]; then
    read -rp "Inserisci l'URL del repository remoto GitHub: " REPO_URL
  fi
  log "Aggiungo il remoto origin -> $REPO_URL"
  git remote add origin "$REPO_URL"
else
  log "Remoto origin già configurato."
fi

# --- Push forzato ---
log "Eseguo il push forzato della nuova history..."
git push origin --force --all
git push origin --force --tags

# --- Backup info ---
if ls .git-history-backup-* &>/dev/null; then
  BACKUP_DIR=$(ls -d .git-history-backup-* | head -n1)
  warn "È stato creato un backup automatico: $BACKUP_DIR"
  warn "Contiene la vecchia cronologia del repo (incluso il file eliminato)."
  warn "Puoi eliminarla in sicurezza con:"
  echo "  rm -rf $BACKUP_DIR"
fi

echo
log "✅ Operazione completata con successo!"
log "Il file '$TARGET_FILE' è stato completamente rimosso dalla history."
