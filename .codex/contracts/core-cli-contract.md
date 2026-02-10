# Core CLI Contract

CLI:
- `python3 src/framework-core/main.py cold-start`
- `python3 src/framework-core/main.py completion`

JSON envelope:
- `status`: `success | error | needs_input`
- `command`: command name
- `timestamp`: ISO UTC
- `tasks`: optional task result list
- `errors`: optional error list
- `data`: optional payload (e.g., crash reason)
- `duration_total_ms`: optional duration

Exit codes:
- `0`: success
- `1`: error
- `2`: needs_input
