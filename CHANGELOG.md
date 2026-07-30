## 0.3.0

- Adds debounced remote search with stale-response protection.
- Adds page-number and cursor pagination through a shared request contract.
- Adds grouped sections with optional sticky and custom headers.
- Adds removable selected-item chips with typed custom builders.
- Adds global and per-sheet loading, empty, error, pagination loading, and
  pagination error builders.
- Adds retry handling for initial and pagination failures.
- Adds programmatic and pull-to-refresh support for remote sheets.

## 0.2.0

- Adds a 300 ms default debounce for local search.
- Adds global and per-sheet search debounce configuration.
- Allows debouncing to be disabled with `Duration.zero`.

## 0.1.0

- Adds typed single and multi-selection sheets.
- Adds local search and disabled-item support.
- Adds draggable heights and keyboard avoidance.
- Adds adaptive Material and Cupertino presentation.
- Adds global theming and per-sheet item builder overrides.
