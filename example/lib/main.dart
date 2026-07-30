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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selection Sheet')),
      body: Center(
        child: FilledButton(
          onPressed: _selectCountry,
          child: Text(selected?.name ?? 'Choose a country'),
        ),
      ),
    );
  }

  Future<void> _selectCountry() async {
    final result = await SelectionSheet.showSingle<Country>(
      context: context,
      items: countries,
      initialValue: selected,
      searchable: true,
      title: 'Country',
      itemLabelBuilder: (country) => country.name,
      itemEquals: (first, second) => first.code == second.code,
      itemBuilder: (context, country, state) {
        return ListTile(
          leading: CircleAvatar(child: Text(country.code)),
          title: Text(country.name),
          subtitle: Text(country.region),
          selected: state.isSelected,
          trailing: state.isSelected ? const Icon(Icons.check) : null,
        );
      },
    );

    if (result != null) setState(() => selected = result);
  }
}

class Country {
  const Country(this.code, this.name, this.region);

  final String code;
  final String name;
  final String region;
}
