**ATTENZIONE:**
prima di eseguire la pulizia della history per un determinato file,
creare una copia di backup del file perchè la procedura `git filter-repo` rimuoverà il file anche 
dal file-system della working direcotry del repo locale.

Ad ogni modo, `git filter-repo` crea una directory `.git-history-backup-<DATE>-<TIME>`  
come backup di sicurezza prima che il tool riscriva la cronologia del repository.

Se la pulizia della history va a buon fine, eliminare anche la directory `.git-history-backup-xxx-xxx`.

---

# 🧹 Rimuovere tutta la history di un file da un repository GitHub

Questa guida spiega come eliminare **completamente la cronologia** di un singolo file (`setup-global-gitignore.sh`) dal repository
👉 [`https://github.com/vitmil/git_scripts`](https://github.com/vitmil/git_scripts),
senza toccare gli altri file o la struttura del progetto.

---

## 🎯 Obiettivo

Eliminare ogni traccia passata del file $FILE_NAME dal repository Git, in modo che:

* non appaia più nei commit precedenti, nei diff o nei log;
* sia impossibile recuperarlo anche da versioni precedenti del repo.

---

## 🧰 Prerequisiti

* Linux o macOS con Git installato
* Accesso in scrittura al repository remoto su GitHub
* Installazione di `git-filter-repo`

---

## ⚙️ 1️⃣ Posizionati nella cartella del repo locale

```bash
cd /usr/local/bin/git_scripts
```

---

## ⚙️ 2️⃣ Installa `git-filter-repo`

Su Ubuntu:

```bash
sudo apt install git-filter-repo
```

oppure, se non disponibile:

```bash
pip install git-filter-repo
```

---

## ⚙️ 3️⃣ Rimuovi il file da tutta la cronologia

Esegui nella radice del repository:

```bash
FILE_NAME=setup-global-gitignore.sh

git filter-repo --path $FILE_NAME --invert-paths
```

✅ Questo comando:

* cancella ogni versione del file $FILE_NAME dalla history;
* mantiene tutto il resto del progetto intatto.

---

## ⚙️ 4️⃣ Pulisci i riferimenti interni (opzionale ma consigliato)

```bash
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

---

## ⚙️ 5️⃣ Configura (o verifica) il remoto GitHub

Controlla se il remoto è già configurato:

```bash
git remote -v
```

Se non vedi nulla, aggiungilo manualmente:

```bash
git remote add origin https://github.com/vitmil/git_scripts.git
```

Verifica:

```bash
git remote -v
```

Dovresti ottenere:

```
origin  https://github.com/vitmil/git_scripts.git (fetch)
origin  https://github.com/vitmil/git_scripts.git (push)
```

---

## ⚙️ 6️⃣ Sovrascrivi la cronologia remota (⚠️ operazione distruttiva)

```bash
git push origin --force --all
git push origin --force --tags
```

🔴 **Attenzione:**
Questa operazione riscrive la history sul server.
Chiunque usi questo repo dovrà riclonarlo da zero:

```bash
git clone https://github.com/vitmil/git_scripts.git
```

---

## ⚙️ 7️⃣ Verifica che il file sia stato rimosso

```bash
git log -- $FILE_NAME
```

Il comando non deve restituire nulla ✅

---

## 🗂️ 8️⃣ La directory `.git-history-backup-YYYYMMDD-HHMMSS`

Dopo l’esecuzione di `git filter-repo`, potresti trovare una directory simile a:

```
.git-history-backup-20251104-131200
```

### 📦 Cosa contiene

* Una **copia completa della vecchia directory `.git`**, cioè la **history originale** prima della pulizia.
* Tutti i commit, tag e riferimenti del repository prima della modifica.
* Anche le versioni passate del file che hai rimosso.

### ⚠️ Posso eliminarla?

Sì, **dopo aver verificato che il repo funzioni correttamente** e che la nuova cronologia sia come desiderato.

Per eliminarla:

```bash
rm -rf .git-history-backup-20251104-131200
```

💡 Se vuoi conservarla solo per sicurezza:

```bash
tar -czf git-history-backup.tar.gz .git-history-backup-20251104-131200
rm -rf .git-history-backup-20251104-131200
```

---

## ✅ RISULTATO FINALE

* Il file $FILE_NAME è completamente rimosso dalla history.
* Il repo su GitHub contiene solo la nuova cronologia pulita.
* La directory `.git-history-backup-*` può essere rimossa o archiviata.
* Tutti i riferimenti alla versione precedente del file sono eliminati in modo permanente.

---
