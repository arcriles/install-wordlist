# install-wordlist
im too lazy to pull all the wordlist for my ctf, so i made a script of my trusted wordlist repo

This script installs popular pentesting wordlists directly into /usr/share/wordlists/ to match common documentation and tool defaults.
Use --heavy to include very large corpora (storage‑intensive).

SCRIPT NAME / PATH
```/usr/local/bin/install-wordlists.sh```

WHAT IT INSTALLS (AND WHERE)
- SecLists -> /usr/share/wordlists/SecLists/
- FuzzDB -> /usr/share/wordlists/FuzzDB/
- Assetnote wordlists -> /usr/share/wordlists/Assetnote/
- dirsearch (db) -> /usr/share/wordlists/dirsearch/   (e.g., db/dicc.txt)
- Trickest wordlists -> /usr/share/wordlists/Trickest/
- PayloadsAllTheThings -> /usr/share/wordlists/PayloadsAllTheThings/
- IntruderPayloads -> /usr/share/wordlists/IntruderPayloads/
- bruteforce-lists -> /usr/share/wordlists/bruteforce-lists/
- (HEAVY) Probable-Wordlists -> /usr/share/wordlists/Probable-Wordlists/

If rockyou.txt.tar.gz exists in SecLists, the script extracts:
- rockyou.txt -> /usr/share/wordlists/rockyou.txt

COMPATIBILITY SYMLINKS (FOR LEGACY DOCS/COMMANDS)
- /usr/share/wordlists/dirbuster/directory-list-2.3-{small,medium,big}.txt
- /usr/share/wordlists/dirbuster/directory-list-lowercase-2.3-{small,medium,big}.txt
- /usr/share/wordlists/Discovery/Web-Content/ -> symlink to SecLists/Discovery/Web-Content/
- Shortcuts:
  - /usr/share/wordlists/raft-small-words.txt
  - /usr/share/wordlists/raft-medium-words.txt
  - /usr/share/wordlists/raft-large-words.txt

PREREQUISITES
- git, tar, and sudo privileges to write under /usr/share/wordlists/.

USAGE
- Core sets:
  sudo /usr/local/bin/install-wordlists.sh
- Include heavy sets:
  sudo /usr/local/bin/install-wordlists.sh --heavy

QUICK VERIFY
  sudo du -sh /usr/share/wordlists
  readlink -f /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt
  readlink -f /usr/share/wordlists/Discovery/Web-Content
  ls -lh /usr/share/wordlists/dirsearch/db/dicc.txt
  [ -f /usr/share/wordlists/rockyou.txt ] && wc -l /usr/share/wordlists/rockyou.txt

EXAMPLES
- Gobuster (classic path):
  ```gobuster dir -u http://target/     -w /usr/share/wordlists/dirbuster/directory-list-2.3-small.txt     -x php,html,txt -t 40 ```

- ffuf (dirsearch DB):
  ```ffuf -u http://target/FUZZ -w /usr/share/wordlists/dirsearch/db/dicc.txt -t 60```

UPDATE
- Re-run the same command; repositories are updated via git pull.

UNINSTALL (MANUAL)
  ```
sudo rm -rf /usr/share/wordlists
  ```

  

NOTE
- The --heavy option consumes a lot of disk space. Use only if you really need the full corpora.
