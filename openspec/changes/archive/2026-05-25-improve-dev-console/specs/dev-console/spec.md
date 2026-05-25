## MODIFIED Requirements

### Requirement: Dev console is toggled with F1 during play
The dev console SHALL be togglable by pressing F1 at any point during a run, including active rounds, shop, keystone selection, and round-end screens. It SHALL be hidden by default. The console node SHALL persist across scene transitions by being registered as a global autoload.

#### Scenario: F1 opens console when closed
- **WHEN** F1 is pressed and the console is not visible
- **THEN** the console panel becomes visible and the text input receives focus

#### Scenario: F1 closes console when open
- **WHEN** F1 is pressed and the console is visible
- **THEN** the console panel is hidden and game input focus is restored

#### Scenario: F1 opens console from the shop screen
- **WHEN** the player is on the shop screen and presses F1
- **THEN** the console panel becomes visible

#### Scenario: F1 opens console from the keystone selection screen
- **WHEN** the player is on the keystone selection screen and presses F1
- **THEN** the console panel becomes visible

### Requirement: Dev console supports a defined command set
The console SHALL accept and execute the following commands, printing a confirmation or error message to the console log. The `give_keystone` and `give_technique` commands SHALL immediately refresh the HUD inventory icons when a `run_manager` is active.

| Command | Effect |
|---------|--------|
| `help` | Print all available commands |
| `skip_round` | End the current round as a success with zero payout |
| `set_stage <n>` | Set the current stage to n (1–5) |
| `add_coins <n>` | Add n coins to the balance |
| `give_keystone <id>` | Add the keystone with the given id to the active run and refresh HUD |
| `give_technique <id>` | Add the technique with the given id to the active run and refresh HUD |
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

#### Scenario: give_keystone refreshes HUD immediately
- **WHEN** `give_keystone <id>` is entered during an active round
- **THEN** the keystone icon appears in the HUD inventory panel without waiting for the next round

#### Scenario: give_technique refreshes HUD immediately
- **WHEN** `give_technique <id>` is entered during an active round
- **THEN** the technique icon appears in the HUD inventory panel without waiting for the next round

### Requirement: Console input pauses piece movement and round timer
While the console is open, the active `TetrisBoard`'s input processing SHALL be suspended and the RunManager's `_paused` flag SHALL be set to `true`, freezing the round timer. Closing the console SHALL restore both.

#### Scenario: Board ignores movement keys while console is open
- **WHEN** the console is open and the player presses the left arrow key
- **THEN** the active piece does not move

#### Scenario: Round timer is frozen while console is open
- **WHEN** the console is opened during an active round
- **THEN** the round timer stops counting down until the console is closed

### Requirement: Console log is scrollable
The console log SHALL display at least the last 20 lines of output and SHALL be scrollable to view earlier output.

#### Scenario: Log scrolls when output exceeds visible area
- **WHEN** more than 20 commands have been entered
- **THEN** the log is scrollable and earlier entries remain accessible
