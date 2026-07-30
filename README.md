# selection_sheet

Adaptive, searchable selection workflows for Flutter.

`selection_sheet` provides typed single and multi-selection sheets with local
search, draggable heights, keyboard avoidance, Material/Cupertino adaptation,
and a theming system that supports both global defaults and per-sheet
overrides.

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

- Remote search with stale-request protection
- Cursor and page-based pagination
- Sections and sticky headers
- Selected-item chips
- Loading, retry, and custom state builders
- Form and `smart_form_fields` integration
