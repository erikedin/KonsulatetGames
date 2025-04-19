Architecture
============
These are initial ideas about the architecture for the Niancat game.

# Architecture
The architecture is a distributed service architecture, using [NATS](https://nats.io) as the
communication platform. With `NATS`, communication is pub-sub, with events published on
channels called "subjects".

# Games
Currently, Niancat is the only game. However, the subjects explicitly include Niancat,
which allows for other games to be added in the future.

# Services
Here is a list of services that communicate over the NATS platform.

- Niancat service: Maintains the puzzle and listens for guesses from players
- Puzzle maker: Chooses a random 9 letter word from the dictionary once a day at 09:09
- Slack integration: Listens to events on the Slack channels and publishes to NATS
- Streak service: Calculates scores by checking streaks

## Additional services
The entire point of this architecture is the ability to add new services. For instance,
the calculation of points by streaks is only one possible way of keeping score. One could
add other services that calculates other scores.

# Game creation and end
> [!note]
> The puzzles here are four letter words, and the unique identifiers are also four letter words,
> to save on previous column space in the documentation.

The `game.niancat.lifetime` subject contains events for creating and destroying game instances.
That is, to start a new game, send a `newgame` event to this subject, with the following
data:

- the puzzle for this new game
- a unique identifier for this game instance

| game.niancat.lifetime                  | game.niancat.instance.cafe | Sent by      |
|----------------------------------------|----------------------------|--------------|
| event: newgame, puzzle: UPSS, id: cafe |                            | Puzzle maker |

The subject `game.niancat.instance.cafe` collects all events relating to this particular Niancat puzzle.
Note that the `.cafe` is the identifier of the game instance.

The service that handles Niancat games will subscribe to `game.niancat.lifetime`. When a `newgame` event
is received, a new Niancat instance will be created with the given puzzle (and the appropriate identifier).
This service will then also subscribe to the subject `game.niancat.instance.<id>`, which would be
`game.niancat.instance.cafe` in the above example. Any guesses made via Slack would be published to
this subject.

| game.niancat.lifetime                  | game.niancat.instance.cafe            | Sent by           |
|----------------------------------------|---------------------------------------|-------------------|
| event: newgame, puzzle: UPSS, id: cafe |                                       | Puzzle maker      |
|                                        | event: guess, user: erike, word: PUSS | Slack integration |

The game instance receives this event, and sends a response, to the same subject.

| game.niancat.lifetime                  | game.niancat.instance.cafe             | Sent by           |
|----------------------------------------|----------------------------------------|-------------------|
| event: newgame, puzzle: UPSS, id: cafe |                                        | Puzzle maker      |
|                                        | event: guess, user: erike, word: PUSS  | Slack integration |
|                                        | event: correct, user:erike, word: PUSS | Niancat game      |

> [!NOTE]
> Note on race conditions
> When a new game instance is created, the game service subscribes to the subject for that
> particular instance. Any events on that subject sent before the game service subscribes to it must
> handled, or they would be lost.

How does the Slack service know which game instance to send the `guess` event to? It will need to
keep track of the latest game instance.

When a game ends, an `endgame` event is sent. This will usually be coupled with a new game being created.

| game.niancat.lifetime                  | game.niancat.instance.cafe             | Sent by           |
|----------------------------------------|----------------------------------------|-------------------|
| event: newgame, puzzle: UPSS, id: cafe |                                        | Puzzle maker      |
|                                        | event: guess, user: erike, word: PUSS  | Slack integration |
|                                        | event: correct, user:erike, word: PUSS | Niancat game      |
| event: endgame, id: cafe               |                                        | Some service?     |

After this point, no further events should be sent to the `game.niancat.instance.cafe` subject.
The "streak points" service will listen to any `endgame` events and calculate the streak based on
previous game instances.

| game.niancat.score.streak           | Sent by      |
|-------------------------------------|--------------|
| erik: 2, sandell: 42, id: cafe      | Streak score |

> [!NOTE]
> Game instance order. The calculation of streaks implies that game instances have an order. This
> order could be implicit in the order of `newgame` events, or one could possibly add a `previous`
> identifier to any new game event that points to the previous game.

# Notes
## Unique identifiers for game instances
In this document, unique identifiers are shortened UUIDs, but this is a placeholder until a decision
is made on unique identifiers. The identifiers must be reasonably unique, but need not necessarily be
UUIDs. While puzzles are normally set once per day, it is not an inconceivable situation that one
would want to set the same puzzle more than once in a day, to work around issues. Therefore, the
puzzle coupled with the date (at a day resolution) is not a sufficient unique identifier. The puzzle
coupled with a second or millisecond timestamp could however be sufficiently unique.

In short, the identifiers here are intended to be reasonably unique, but may not be UUIDs.

Note that in the above NATS subjects, the identifier is used as part of the subject. Therefore the
unique identifier for the game instance would need to conform to the NATS naming constraints.
More information on those contraints can be found at
https://docs.nats.io/nats-concepts/subjects#characters-allowed-and-recommended-for-subject-names.

The identifier type may not even be strictly defined. It may be a decision left to the service
that creates new puzzles. All other services may treat it as an opaque string and assume that
it is unique.