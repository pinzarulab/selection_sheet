import 'package:flutter/material.dart';
import 'package:selection_sheet/selection_sheet.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selection Sheet',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      builder: (context, child) {
        return SelectionSheetTheme(
          data: SelectionSheetThemeData.fallback(context).copyWith(
            selectedColor: Colors.indigo.shade50,
          ),
          child: child!,
        );
      },
      home: const CountryPage(),
    );
  }
}

class CountryPage extends StatefulWidget {
  const CountryPage({super.key});

  @override
  State<CountryPage> createState() => _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  static const countries = [
    Country('FR', 'France', 'Europe'),
    Country('DE', 'Germany', 'Europe'),
    Country('JP', 'Japan', 'Asia'),
    Country('UA', 'Ukraine', 'Europe'),
  ];

  Country? selected;
  List<Country> selectedCountries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selection Sheet')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 320,
              child: SelectionSheetFormField<Country>(
                items: countries,
                initialValue: selected,
                searchable: true,
                title: 'Country',
                decoration: const InputDecoration(labelText: 'Country'),
                itemLabelBuilder: (country) => country.name,
                itemEquals: (first, second) => first.code == second.code,
                validator: (country) =>
                    country == null ? 'Choose a country' : null,
                onChanged: (country) => setState(() => selected = country),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _selectCountriesRemotely,
              child: Text(
                selectedCountries.isEmpty
                    ? 'Remote multi-selection'
                    : '${selectedCountries.length} countries selected',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectCountriesRemotely() async {
    final result = await SelectionSheet.showMulti<Country>(
      context: context,
      loadItems: (request) async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        request.cancellationToken.throwIfCancelled();
        final matches = countries.where((country) {
          return country.name.toLowerCase().contains(
                request.query.toLowerCase(),
              );
        }).toList();
        final start = (request.page - 1) * request.pageSize;
        if (start >= matches.length) {
          return const SelectionSheetPage(items: []);
        }
        final end = (start + request.pageSize).clamp(0, matches.length);
        return SelectionSheetPage(
          items: matches.sublist(start, end),
          hasMore: end < matches.length,
        );
      },
      pageSize: 2,
      initialSelection: selectedCountries,
      searchable: true,
      title: 'Remote countries',
      itemLabelBuilder: (country) => country.name,
      itemEquals: (first, second) => first.code == second.code,
      sectionBuilder: (country) => country.region,
      layout: SelectionSheetLayout.grid,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, country, state) {
        return Card(
          color: state.isSelected
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
          child: Center(child: Text('${country.code}  ${country.name}')),
        );
      },
      sectionHeaderBuilder: (context, section) {
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(section.label),
            ),
          ),
        );
      },
    );

    if (result != null) setState(() => selectedCountries = result);
  }
}

class Country {
  const Country(this.code, this.name, this.region);

  final String code;
  final String name;
  final String region;
}
