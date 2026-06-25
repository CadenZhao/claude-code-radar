# One-tap launch from your laptop

If your Claude Code projects live on a remote server, you can turn the whole
Mission Control dashboard into a single click from your Mac: tap an icon, approve
with Touch ID, read the dashboard, close the window to disconnect.

This guide has two parts: a **generic** setup that works with any SSH server, and
an **example university-HPC** walkthrough with its typical caveats (VPN, two-factor,
login nodes).

---

## Generic setup (any SSH server)

### 1. Create an SSH key (once)

```bash
ssh-keygen -t ed25519 -C "laptop-to-server"
```

Press Enter for the default path. Setting a passphrase is recommended — you'll
hand it to the macOS keychain next, so you won't type it again.

Store the passphrase in the keychain so Touch ID can unlock it:

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

### 2. Install the public key on the server (once)

```bash
ssh-copy-id you@your.server
```

This asks for your server password one last time. After this, key auth takes over.

### 3. Add an SSH shortcut

Append to `~/.ssh/config` on your laptop:

```
Host myserver
    HostName your.server
    User you
    IdentityFile ~/.ssh/id_ed25519
    UseKeychain yes
    AddKeysToAgent yes
```

Verify password-free login:

```bash
ssh myserver
```

### 4. Make an iTerm profile

1. iTerm → Settings → Profiles → `+` → name it "Mission Control".
2. **General → Command**: choose "Command", enter:
   ```
   ssh -t myserver "~/mission-control/ccradar.sh /path/to/projects; echo; read -n1 -p 'Press any key to close...'"
   ```
   This SSHes in, prints the dashboard directly (no AI, instant), and waits for a
   keypress so you can read it before the window closes.
3. **Session → When session ends**: choose "Close" (window closes on exit).

### 5. Make a clickable icon

macOS Shortcuts app → new shortcut → add "Run AppleScript":

```applescript
tell application "iTerm"
    create window with profile "Mission Control"
end tell
```

Save and drag it to the Dock. One click runs the whole chain.

The full flow becomes: **click icon → Touch ID → read dashboard → close window
(auto-disconnect).**

---

## Example: a university HPC cluster

Many universities run a shared HPC cluster. The setup above works there too, with
three caveats common to that kind of environment.

### Caveat 1 — VPN required off-campus

From off-campus you often must connect to the campus VPN (e.g. Cisco AnyConnect)
before SSH will reach the cluster. On campus / campus Wi-Fi, no VPN needed.

### Caveat 2 — two-factor

Many campuses require two-factor (e.g. Duo). In practice, once your SSH key is
installed, key-based logins may go through without a password or a 2FA prompt.
Your mileage may vary; test with `ssh you@hpc.example.edu` and see what it asks for.

### Caveat 3 — Never run compute on the login node

This is the big one for data analysis. HPC login nodes are for editing,
light commands, and submitting jobs — **not** for running your actual analyses.
Heavy work must be submitted to SLURM (`srun` / `sbatch`) on a compute node.

The radar itself is fine on a login node: it only runs lightweight read-only
commands (`find`, `grep`, `git`). But don't use this one-tap login to then launch
a big Claude Code analysis on the login node — request a compute node first.

### Example cluster values

```
# ~/.ssh/config
Host hpc
    HostName hpc.example.edu
    User your_username
    IdentityFile ~/.ssh/id_ed25519
    UseKeychain yes
    AddKeysToAgent yes
```

```
# iTerm profile command
ssh -t hpc "~/mission-control/ccradar.sh /work/users/<username>; echo; read -n1 -p 'Press any key to close...'"
```

Off-campus daily flow: **connect VPN → click icon → (possibly one 2FA tap) →
read dashboard → close window.**

Home directories on many clusters are small; real projects often live under a
scratch/work area like `/work/users/<username>`. Point the scanner there in your
`CLAUDE.md`.
