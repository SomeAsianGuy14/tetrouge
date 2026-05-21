## ADDED Requirements

### Requirement: Dev console is toggled with F1 during play
The dev console SHALL be togglable by pressing F1 at any point during a run (including during active rounds and between rounds). It SHALL be hidden by default.

#### Scenario: F1 opens console when closed
- **WHEN** F1 is pressed and the console is not visible
- **THEN** the console panel becomes visible and the text input receives focus

#### Scenario: F1 closes console when open
- **WHEN** F1 is pressed and the console is visible
- **THEN** the console panel is hidden and game input focus is restored

### Requirement: Dev console supports a defined command set
The console SHALL accept and execute the following commands, printing a confirmation or error message to the console log:

| Command | Effect |
|---------|--------|
| `help` | Print all available commands |
| `skip_round` | End the current round as a success with zero payout |
| `set_ante <n>` | Set the current ante to n (1–5) |
| `add_coins <n>` | Add n coins to the balance |
| `give_keystone <id>` | Add the keystone with the given id to the active run |
| `give_technique <id>` | Add the technique with the given id to the active run |
| `insert_garbage <n>` | Insert n garbage rows into the active board |
| `set_quota <n>` | Set the current round quota to n |

#### Scenario: Valid command executes and logs confirmation
- **WHEN** `add_coins 10` is entered and submitted
- **THEN** 10 coins are added to the balance and the console logs "Added 10 coins. Balance: X"

#### Scenario: Unknown command logs an error
- **WHEN** an unrecognised command string is entered
- **THEN** the console logs "Unknown command: <input>. Type 'help' for commands."

#### Scenario: help lists all commands
- **WHEN** `help` is entered
- **THEN** the console log displays all supported commands with one-line descriptions

### Requirement: Console input pauses piece movement
While the console is open, the active `TetrisBoard`'s input processing SHALL be suspended so that typing in the console does not move pieces.

#### Scenario: Board ignores movement keys while console is open
- **WHEN** the console is open and the player presses the left arrow key
- **THEN** the active piece does not move

### Requirement: Console log is scrollable
The console log SHALL display at least the last 20 lines of output and SHALL be scrollable to view earlier output.

#### Scenario: Log scrolls when output exceeds visible area
- **WHEN** more than 20 commands have been entered
- **THEN** the log is scrollable and earlier entries remain accessible
