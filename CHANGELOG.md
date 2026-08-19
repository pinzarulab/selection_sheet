## 0.6.1

- Prevents Android handle gestures from being processed by two drag owners,
  which could pop two routes and leave a black screen.
- Makes a downward list drag at scroll offset zero dismiss the sheet
  consistently on Android and iOS.

## 0.6.0

- Makes default and custom drag handles resize Material and Cupertino sheets.
- Adds drag-to-dismiss behavior for Cupertino sheet handles.
- Adds `enableDrag: false` for a strict initial sheet height with independently
  scrolling content.

## 0.5.1

- Prevents sticky section headers from accumulating and obscuring the final
  section while scrolling.
- Adds per-workflow `showDragHandle` control and hides the handle by default
  for non-draggable embedded views.
- Adds global and per-workflow `dragHandleBuilder` customization.
- Updates the example with a full-height embedded workflow and custom handle.

## 0.5.0

- Adds stable item identity with `itemKeyBuilder` for selection matching and
  pagination deduplication.
- Adds custom search inputs with global theme defaults and per-sheet overrides.
- Exposes `SelectionSheetView<T>` for embedded single and multi-selection
  workflows.
- Propagates item identity and custom search inputs through native form fields.
- Adds the optional `SelectionSheetViewItem<T>` configuration object to
  `showSingle` and `showMulti`.
- Refreshes the example app with interactive form, modal, remote grid, custom
  search, and embedded-view demonstrations.

## 0.4.0

- Adds cooperative cancellation tokens to every async page request.
- Cancels superseded search, refresh, pagination, and dismissed-sheet requests.
- Adds globally and locally configurable grid presentation.
- Adds native single and multi Flutter `FormField` widgets.
- Keeps form-field hints optional to avoid duplicating an input label.

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
