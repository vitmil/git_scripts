#!/usr/bin/env bash
# Analisi approfondita di un repository Git locale e dei metodi di autenticazione
# Versione: 2.0

REPO_DIR=${1:-$(pwd)}

if [ ! -d "$REPO_DIR/.git" ]; then
  echo "❌ Nessuna directory .git trovata in $REPO_DIR"
  exit 1
fi

echo "📁 Analizzando repository: $REPO_DIR"
cd "$REPO_DIR" || exit 1

echo "────────────────────────────────────"
echo "🔧 CONFIGURAZIONE GIT"
echo "────────────────────────────────────"
git config --list

REMOTE_URL=$(git config --get remote.origin.url)
if [ -z "$REMOTE_URL" ]; then
  echo "⚠️ Nessun remoto configurato"
  exit 0
fi

echo
echo "🌐 URL remoto: $REMOTE_URL"

# Determina tipo di protocollo
if [[ "$REMOTE_URL" == git@* ]]; then
  AUTH_METHOD="SSH"
elif [[ "$REMOTE_URL" == https://* ]]; then
  AUTH_METHOD="HTTPS"
else
  AUTH_METHOD="Sconosciuto"
fi
echo "🔑 Metodo di autenticazione: $AUTH_METHOD"

# Verifica eventuale file di credenziali
if [ -f "$HOME/.git-credentials" ]; then
  echo "📂 Trovato file di credenziali: ~/.git-credentials"
  echo "→ Contenuto (senza password):"
  grep -oE 'https://[^:]+@[^ ]+' "$HOME/.git-credentials" | sed 's/:.*@/@/' || echo "  Nessuna credenziale leggibile"
fi

echo
echo "────────────────────────────────────"
echo "🔒 METODI DI STORAGE CREDENZIALI DISPONIBILI"
echo "────────────────────────────────────"
echo "Configura con: git config --global credential.helper <metodo>"
echo
echo "• store          → ~/.git-credentials (plaintext)"
echo "• cache          → RAM temporanea"
echo "• osxkeychain    → macOS Keychain"
echo "• wincred        → Windows Credential Manager"
echo "• manager        → Git Credential Manager (GCM)"
echo "• libsecret      → GNOME Keyring"
echo

# Controllo helper attivi
REPO_HELPER=$(git config --local credential.helper)
GLOBAL_HELPER=$(git config --global credential.helper)

echo "────────────────────────────────────"
echo "💾 CONFIGURAZIONE HELPER ATTIVA"
echo "────────────────────────────────────"
if [ -n "$REPO_HELPER" ]; then
  echo "Helper configurato per questo repo: $REPO_HELPER"
else
  echo "Nessun helper locale configurato per il repo"
fi

if [ -n "$GLOBAL_HELPER" ]; then
  echo "Helper globale configurato: $GLOBAL_HELPER"
else
  echo "Nessun helper globale configurato"
fi

# Rileva helper effettivo (priorità: locale > globale)
ACTIVE_HELPER=${REPO_HELPER:-$GLOBAL_HELPER}
if [ -n "$ACTIVE_HELPER" ]; then
  echo "✅ Helper effettivamente utilizzato: $ACTIVE_HELPER"
else
  echo "⚠️ Nessun metodo di storage configurato (usa credenziali manuali)"
fi

# Verifica gestori installati sul sistema
echo
echo "────────────────────────────────────"
echo "🧩 GESTORI DI CREDENZIALI INSTALLATI"
echo "────────────────────────────────────"

CHECK_BIN() {
  command -v "$1" &>/dev/null && echo "✔️  $1 è installato"
}

CHECK_BIN git-credential-manager
CHECK_BIN gnome-keyring-daemon
CHECK_BIN secret-tool
CHECK_BIN git-credential-libsecret
CHECK_BIN git-credential-store
CHECK_BIN git-credential-cache
CHECK_BIN git-credential-wincred
CHECK_BIN git-credential-osxkeychain

# Verifica stato pubblico/privato per GitHub
if [[ "$REMOTE_URL" =~ github\.com[:/](.+)/(.+)\.git ]]; then
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"
  echo
  echo "────────────────────────────────────"
  echo "🔍 VERIFICA PUBBLICO/PRIVATO (GitHub)"
  echo "────────────────────────────────────"

  API_URL="https://api.github.com/repos/$OWNER/$REPO"
  RESPONSE=$(curl -s -H "Accept: application/vnd.github.v3+json" "$API_URL")
  PRIVATE=$(echo "$RESPONSE" | grep '"private"' | awk -F ': ' '{print $2}' | tr -d ',')
  if [[ "$PRIVATE" == "true" ]]; then
    echo "🔒 Il repository è PRIVATO"
  elif [[ "$PRIVATE" == "false" ]]; then
    echo "🌍 Il repository è PUBBLICO"
  else
    echo "⚠️ Impossibile determinare lo stato (API non accessibile o non GitHub)"
  fi
fi

echo
echo "✅ Analisi completata."
exit 0