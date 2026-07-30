# selection_sheet

Adaptive, searchable selection workflows for Flutter.

`selection_sheet` provides typed single and multi-selection sheets with local
and remote search, pagination, grouped results, draggable heights, keyboard
avoidance, Material/Cupertino adaptation, and a theming system that supports
both global defaults and per-sheet overrides.

## Single selection

```dart
final country = await SelectionSheet.showSingle<Country>(
  context: context,
  items: countries,
  searchable: true,
  searchDebounceDuration: const Duration(milliseconds: 400),
  title: 'Country',
  itemLabelBuilder: (country) => country.name,
);
```

Search uses a 300 ms debounce by default. Override it for an individual sheet
with `searchDebounceDuration`, or configure it globally:

```dart
SelectionSheetThemeData.fallback(context).copyWith(
  searchDebounceDuration: const Duration(milliseconds: 500),
);
```

Use `Duration.zero` when filtering should happen immediately.

## Remote search and pagination

Use `loadItems` instead of `items`. Every request contains the current
debounced query, a one-based page number, the requested page size, and the
cursor returned by the previous page.

```dart
final users = await SelectionSheet.showMulti<User>(
  context: context,
  searchable: true,
  pageSize: 30,
  itemLabelBuilder: (user) => user.name,
  loadItems: (request) async {
    final result = await repository.searchUsers(
      query: request.query,
      page: request.page,
      limit: request.pageSize,
      cursor: request.cursor,
    );

    return SelectionSheetPage(
      items: result.users,
      hasMore: result.hasMore,
      nextCursor: result.nextCursor,
    );
  },
);
```

Page-based repositories can ignore `request.cursor`. Cursor-based repositories
can ignore `request.page`. When a new search begins, responses from all older
search generations are ignored automatically.

### Refreshing remote results

Pass a controller when another part of the application needs to refresh the
open sheet:

```dart
final selectionController = SelectionSheetController();

SelectionSheet.showMulti<User>(
  context: context,
  controller: selectionController,
  loadItems: repository.loadUsers,
  itemLabelBuilder: (user) => user.name,
);

await selectionController.refresh();
```

`refresh()` reloads page one for the current debounced query, resets the cursor,
invalidates older requests, and preserves the draft selection. Remote result
lists also support pull-to-refresh by default. Set
`enablePullToRefresh: false` to disable that gesture.

## Multi-selection

Multi-selection is kept as a draft until the user confirms it.

```dart
final countries = await SelectionSheet.showMulti<Country>(
  context: context,
  items: allCountries,
  initialSelection: selectedCountries,
  searchable: true,
  title: 'Countries',
  itemLabelBuilder: (country) => country.name,
);
```

Selected items appear as removable chips by default. Customize them with a
typed builder or disable them with `showSelectedChips: false`:

```dart
selectedChipBuilder: (context, country, label, onDeleted) {
  return InputChip(
    avatar: CountryFlag(code: country.code),
    label: Text(label),
    onDeleted: onDeleted,
  );
},
```

## Sections and sticky headers

```dart
SelectionSheet.showSingle<User>(
  context: context,
  items: users,
  itemLabelBuilder: (user) => user.name,
  sectionBuilder: (user) => user.department,
  stickySectionHeaders: true,
  sectionHeaderBuilder: (context, section) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Text('${section.label} (${section.itemCount})'),
    );
  },
);
```

Section order follows the first occurrence of each key in the loaded items.

## Loading, empty, and error states

All initial and pagination states have per-sheet builders:

```dart
SelectionSheet.showSingle<User>(
  context: context,
  loadItems: repository.loadUsers,
  itemLabelBuilder: (user) => user.name,
  loadingBuilder: (context) => const UserListSkeleton(),
  emptyBuilder: (context, query) => EmptyUsers(query: query),
  errorBuilder: (context, error, retry) {
    return ErrorPanel(error: error, onRetry: retry);
  },
  loadingMoreBuilder: (context) => const LoadingMoreRow(),
  loadMoreErrorBuilder: (context, error, retry) {
    return RetryPageRow(onRetry: retry);
  },
);
```

The same builders can be configured globally in `SelectionSheetThemeData`.

## Custom item rows

The label builder remains the source for search and semantics. A typed item
builder can replace the visual row:

```dart
final country = await SelectionSheet.showSingle<Country>(
  context: context,
  items: countries,
  itemLabelBuilder: (country) => country.name,
  itemBuilder: (context, country, state) {
    return ListTile(
      leading: CountryFlag(code: country.code),
      title: Text(country.name),
      selected: state.isSelected,
      trailing: state.isSelected ? const Icon(Icons.check) : null,
    );
  },
);
```

## Global design

Place `SelectionSheetTheme` inside `MaterialApp.builder`:

```dart
MaterialApp(
  builder: (context, child) {
    return SelectionSheetTheme(
      data: SelectionSheetThemeData.fallback(context).copyWith(
        selectedColor: Colors.indigo.shade50,
        showDividers: true,
        itemBuilder: (context, item) {
          return AppSelectionTile(
            label: item.label,
            selected: item.isSelected,
          );
        },
      ),
      child: child!,
    );
  },
  home: const App(),
);
```

A typed `itemBuilder` passed to `showSingle` or `showMulti` overrides the global
builder. A sheet can also override design tokens:

```dart
SelectionSheet.showSingle<Country>(
  context: context,
  items: countries,
  itemLabelBuilder: (country) => country.name,
  theme: SelectionSheetTheme.of(context).copyWith(
    selectedColor: Colors.green.shade100,
    showDividers: false,
  ),
);
```

## Roadmap

- Form and `smart_form_fields` integration
- Async request cancellation hooks
- Grid presentation
