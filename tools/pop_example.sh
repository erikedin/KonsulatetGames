#!/usr/bin/env bash

nats pub game.niancat.lifetime '{"event": "newgame", "puzzle": "UPSSGURKA", "timestamp": "2025-04-19T09:09:09+01:00", "id": "e9a194d1-a75e-4e6f-aa1b-3f70ba8b032c"}'
nats pub game.niancat.lifetime '{"event": "endgame", "timestamp": "2025-04-20T09:09:08+01:00", "id": "e9a194d1-a75e-4e6f-aa1b-3f70ba8b032c"}'
nats pub game.niancat.lifetime '{"event": "newgame", "puzzle": "PSELDATOR", "timestamp": "2025-04-20T09:09:09+01:00", "id": "adae093c-e794-4245-a419-c67bcf4ab526"}'

nats pub game.niancat.instance.e9a194d1-a75e-4e6f-aa1b-3f70ba8b032c '{"event": "solution", "word": "PUSSGURKA", "timestamp": "2025-04-19T10:09:09+01:00", "user": "erike"}'
nats pub game.niancat.instance.e9a194d1-a75e-4e6f-aa1b-3f70ba8b032c '{"event": "unsolution", "text": "This is not a solution", "timestamp": "2025-04-19T11:09:09+01:00", "user": "erike"}'

nats pub game.niancat.point.streak '{"event": "streaks", "streaks": [{"erike": 1}], "timestamp": "2025-04-20T09:09:09+01:00"}'