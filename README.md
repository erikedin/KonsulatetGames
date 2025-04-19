# KonsulatetGames
Word games for our Slack.

# Development prerequisities
Nix is used to maintain a consistent development environment across computers.
Install it from https://nix.dev/install-nix#install-nix.

To start a development shell, in the root directory (where `shell.nix` resides), run

```bash
$ nix-shell
[nix-shell:path/to/KonsulatetGames]$
```

In this shell, the developer will currently have access to

- `nats-server`