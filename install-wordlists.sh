#!/usr/bin/env bash
set -euo pipefail

HEAVY=0
[[ "${1:-}" == "--heavy" ]] && HEAVY=1

DEST="/usr/share/wordlists"
sudo mkdir -p "$DEST"
sudo chown -R root:root "$DEST"
sudo chmod -R a+rx "$DEST"

need() { command -v "$1" >/dev/null 2>&1 || { echo "Missing: $1"; exit 1; }; }
need git
need tar

clone_or_update () {
  local repo_url="$1" dest_dir="$2"
  if [[ -d "$dest_dir/.git" ]]; then
    echo "[*] Force updating $dest_dir, discarding local changes"
    (
      cd "$dest_dir"
      sudo git fetch origin
      sudo git reset --hard origin/master
      sudo git pull
    )
  else
    echo "[*] Cloning $repo_url -> $dest_dir"
    sudo git clone --depth=1 "$repo_url" "$dest_dir"
  fi
  sudo find "$dest_dir" -type d -exec chmod a+rx {} \; 2>/dev/null || true
  sudo find "$dest_dir" -type f -exec chmod a+r {} \; 2>/dev/null || true
}

echo "[*] Install path: $DEST"

# --- Core repos (disarankan) ---
clone_or_update "https://github.com/danielmiessler/SecLists.git"            "$DEST/SecLists"
clone_or_update "https://github.com/fuzzdb-project/fuzzdb.git"              "$DEST/FuzzDB"
clone_or_update "https://github.com/assetnote/wordlists.git"                "$DEST/Assetnote"
clone_or_update "https://github.com/maurosoria/dirsearch.git"               "$DEST/dirsearch"
clone_or_update "https://github.com/trickest/wordlists.git"                 "$DEST/Trickest"
clone_or_update "https://github.com/swisskyrepo/PayloadsAllTheThings.git"   "$DEST/PayloadsAllTheThings"
clone_or_update "https://github.com/1N3/IntruderPayloads.git"               "$DEST/IntruderPayloads"
clone_or_update "https://github.com/random-robbie/bruteforce-lists.git"     "$DEST/bruteforce-lists"
clone_or_update "https://github.com/TheKingOfDuck/fuzzDicts.git"            "$DEST/fuzzDicts"

# --- Optional heavy sets ---
if [[ "$HEAVY" -eq 1 ]]; then
  clone_or_update "https://github.com/berzerk0/Probable-Wordlists.git"      "$DEST/Probable-Wordlists"
fi

# --- Convenience: extract rockyou.txt if present in SecLists tarball
ROCK_TARBALL="$DEST/SecLists/Passwords/Leaked-Databases/rockyou.txt.tar.gz"
if [[ -f "$ROCK_TARBALL" && ! -f "$DEST/rockyou.txt" ]]; then
  echo "[*] Extracting rockyou.txt to $DEST"
  sudo tar -xzf "$ROCK_TARBALL" -C "$DEST"
  sudo chmod a+r "$DEST/rockyou.txt"
fi

# --- Compatibility symlinks untuk path 'klasik'
# 1) DirBuster naming (tanpa prefix 'DirBuster-2007_')
DB_SRC="$DEST/SecLists/Discovery/Web-Content"
sudo mkdir -p "$DEST/dirbuster"
for size in small medium big; do
  src="$DB_SRC/DirBuster-2007_directory-list-2.3-$size.txt"
  [[ -f "$src" ]] && sudo ln -sf "$src" "$DEST/dirbuster/directory-list-2.3-$size.txt"
  src_low="$DB_SRC/DirBuster-2007_directory-list-lowercase-2.3-$size.txt"
  [[ -f "$src_low" ]] && sudo ln -sf "$src_low" "$DEST/dirbuster/directory-list-lowercase-2.3-$size.txt"
done

# 2) Shortcut agar path docs lama tetap works
#    /usr/share/wordlists/Discovery/Web-Content -> SecLists/.../Discovery/Web-Content
sudo mkdir -p "$DEST/Discovery"
[[ -d "$DEST/Discovery/Web-Content" ]] || sudo ln -s "$DEST/SecLists/Discovery/Web-Content" "$DEST/Discovery/Web-Content"

# 3) Shortcut umum untuk raft-* (sering dipakai)
for f in raft-small-words.txt raft-medium-words.txt raft-large-words.txt; do
  [[ -f "$DB_SRC/$f" ]] && sudo ln -sf "$DB_SRC/$f" "$DEST/$f"
done

# 4) Symlink for fuzzDicts to /usr/share/fuzzDicts
[[ -L "/usr/share/fuzzDicts" ]] || sudo ln -s "$DEST/fuzzDicts" "/usr/share/fuzzDicts"


# Permissions final
sudo find "$DEST" -type d -exec chmod a+rx {} \;
sudo find "$DEST" -type f -exec chmod a+r {} \;

echo
echo "[*] Done."
sudo du -sh "$DEST" | awk '{print "  Total size:", $1}'
echo "  Files (txt/lst/dic): $(sudo find "$DEST" -type f \( -iname "*.txt" -o -iname "*.lst" -o -iname "*.dic" \) | wc -l)"
echo
echo "[*] Examples:"
echo "  gobuster dir -u http://target/ -w $DEST/dirbuster/directory-list-2.3-small.txt -x php,html,txt -t 40"
echo "  ffuf -u http://target/FUZZ -w $DEST/dirsearch/db/dicc.txt -t 50"