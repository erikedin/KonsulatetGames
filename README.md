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

- `nats-server`, and an associated command line tool `nats`

## Example data
To populate a running NATS server with example data, first run a `nats-server` in
a terminal, inside a running Nix environment.

```
$ nats-server -js
```

The option `-js` enables the use of JetStream, which is a persistent feature of
NATS.

Next, subscribe to all events under any `game.niancat` subject.

```bash
$ nats sub 'game.niancat.>'
```

Run the `tools/pop_examples.sh` shell script, which uses the `nats` command
line tool to publish a set of events.

> [!note] These events are currently only place-holder events. They are not
> to be considered definitive or in any way stable.

```bash
$ bash tools/pop_examples.sh
```

The subscription should now show a list of new events that were just published.