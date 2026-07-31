import 'package:flutter/material.dart';
import 'package:selection_sheet/selection_sheet.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Selection Sheet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff4f46e5),
        ),
        inputDecorationTheme: const InputDecorationTheme(filled: true),
        useMaterial3: true,
      ),
      builder: (context, child) {
        return SelectionSheetTheme(
          data: SelectionSheetThemeData.fallback(context).copyWith(
            selectedColor: Theme.of(context).colorScheme.primaryContainer,
            searchFieldBuilder: _buildSearchField,
            showDividers: false,
          ),
          child: child!,
        );
      },
      home: const CountryShowcasePage(),
    );
  }
}

Widget _buildSearchField(
  BuildContext context,
  SelectionSheetSearchFieldData search,
) {
  return AnimatedBuilder(
    animation: search.controller,
    builder: (context, child) {
      return TextField(
        controller: search.controller,
        focusNode: search.focusNode,
        onChanged: search.onChanged,
        decoration: InputDecoration(
          hintText: search.hintText,
          prefixIcon: const Icon(Icons.travel_explore),
          suffixIcon: search.controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: search.onClear,
                  icon: const Icon(Icons.close),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      );
    },
  );
}

class CountryShowcasePage extends StatefulWidget {
  const CountryShowcasePage({super.key});

  @override
  State<CountryShowcasePage> createState() => _CountryShowcasePageState();
}

class _CountryShowcasePageState extends State<CountryShowcasePage> {
  /*static const countries = [
    Country('AR', 'Argentina', 'Americas'),
    Country('BR', 'Brazil', 'Americas'),
    Country('CA', 'Canada', 'Americas'),
    Country('FR', 'France', 'Europe'),
    Country('DE', 'Germany', 'Europe'),
    Country('IT', 'Italy', 'Europe'),
    Country('UA', 'Ukraine', 'Europe'),
    Country('IN', 'India', 'Asia'),
    Country('JP', 'Japan', 'Asia'),
    Country('KR', 'South Korea', 'Asia'),
    Country('AU', 'Australia', 'Oceania'),
    Country('NZ', 'New Zealand', 'Oceania'),
  ];*/
  static const countries = [
    // Americas
    Country('AR', 'Argentina', 'Americas'),
    Country('BR', 'Brazil', 'Americas'),
    Country('CA', 'Canada', 'Americas'),
    Country('CL', 'Chile', 'Americas'),
    Country('CO', 'Colombia', 'Americas'),
    Country('MX', 'Mexico', 'Americas'),
    Country('PE', 'Peru', 'Americas'),
    Country('US', 'United States', 'Americas'),
    Country('UY', 'Uruguay', 'Americas'),

    // Europe
    Country('AT', 'Austria', 'Europe'),
    Country('BE', 'Belgium', 'Europe'),
    Country('BG', 'Bulgaria', 'Europe'),
    Country('CH', 'Switzerland', 'Europe'),
    Country('CZ', 'Czech Republic', 'Europe'),
    Country('DE', 'Germany', 'Europe'),
    Country('DK', 'Denmark', 'Europe'),
    Country('ES', 'Spain', 'Europe'),
    Country('FI', 'Finland', 'Europe'),
    Country('FR', 'France', 'Europe'),
    Country('GB', 'United Kingdom', 'Europe'),
    Country('GR', 'Greece', 'Europe'),
    Country('HR', 'Croatia', 'Europe'),
    Country('HU', 'Hungary', 'Europe'),
    Country('IE', 'Ireland', 'Europe'),
    Country('IT', 'Italy', 'Europe'),
    Country('LT', 'Lithuania', 'Europe'),
    Country('LV', 'Latvia', 'Europe'),
    Country('MD', 'Moldova', 'Europe'),
    Country('NL', 'Netherlands', 'Europe'),
    Country('NO', 'Norway', 'Europe'),
    Country('PL', 'Poland', 'Europe'),
    Country('PT', 'Portugal', 'Europe'),
    Country('RO', 'Romania', 'Europe'),
    Country('RS', 'Serbia', 'Europe'),
    Country('SE', 'Sweden', 'Europe'),
    Country('SK', 'Slovakia', 'Europe'),
    Country('TR', 'Turkey', 'Europe'),
    Country('UA', 'Ukraine', 'Europe'),

    // Asia
    Country('AE', 'United Arab Emirates', 'Asia'),
    Country('CN', 'China', 'Asia'),
    Country('HK', 'Hong Kong', 'Asia'),
    Country('ID', 'Indonesia', 'Asia'),
    Country('IL', 'Israel', 'Asia'),
    Country('IN', 'India', 'Asia'),
    Country('JP', 'Japan', 'Asia'),
    Country('KR', 'South Korea', 'Asia'),
    Country('MY', 'Malaysia', 'Asia'),
    Country('PH', 'Philippines', 'Asia'),
    Country('SA', 'Saudi Arabia', 'Asia'),
    Country('SG', 'Singapore', 'Asia'),
    Country('TH', 'Thailand', 'Asia'),
    Country('TW', 'Taiwan', 'Asia'),
    Country('VN', 'Vietnam', 'Asia'),

    // Africa
    Country('DZ', 'Algeria', 'Africa'),
    Country('EG', 'Egypt', 'Africa'),
    Country('KE', 'Kenya', 'Africa'),
    Country('MA', 'Morocco', 'Africa'),
    Country('NG', 'Nigeria', 'Africa'),
    Country('TN', 'Tunisia', 'Africa'),
    Country('ZA', 'South Africa', 'Africa'),

    // Oceania
    Country('AU', 'Australia', 'Oceania'),
    Country('FJ', 'Fiji', 'Oceania'),
    Country('NZ', 'New Zealand', 'Oceania'),
    Country('PG', 'Papua New Guinea', 'Oceania'),
  ];
  Country? formCountry;
  Country? modalCountry;
  List<Country> remoteCountries = [];
  List<Country> embeddedCountries = const [
    Country('UA', 'Ukraine', 'Europe'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('selection_sheet'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Chip(label: Text('v0.5.0'))),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          const _IntroCard(),
          const SizedBox(height: 16),
          _ShowcaseCard(
            icon: Icons.fact_check_outlined,
            title: 'Native form field',
            description:
                'Validation, stable identity, and the globally customized '
                'search input.',
            child: SelectionSheetFormField<Country>(
              items: countries,
              initialValue: formCountry,
              searchable: true,
              title: 'Choose a country',
              decoration: const InputDecoration(
                labelText: 'Country',
                hintText: 'Required',
              ),
              itemLabelBuilder: (country) => country.name,
              itemKeyBuilder: (country) => country.code,
              validator: (country) =>
                  country == null ? 'Choose a country' : null,
              onChanged: (country) => setState(() => formCountry = country),
            ),
          ),
          const SizedBox(height: 16),
          _ShowcaseCard(
            icon: Icons.vertical_align_top_outlined,
            title: 'Modal workflows',
            description:
                'Open a local single selector or a paginated remote grid.',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _selectOne,
                  icon: const Icon(Icons.public),
                  label: Text(modalCountry?.name ?? 'Select one'),
                ),
                OutlinedButton.icon(
                  onPressed: _selectRemotely,
                  icon: const Icon(Icons.cloud_outlined),
                  label: Text(
                    remoteCountries.isEmpty
                        ? 'Remote multi-select'
                        : '${remoteCountries.length} selected',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ShowcaseCard(
            icon: Icons.dashboard_customize_outlined,
            title: 'Embedded SelectionSheetView',
            badge: 'New in 0.5.0',
            description:
                'The complete selection workflow can now live inside any '
                'page, panel, or dialog.',
            child: SizedBox(
              height: 460,
              child: SelectionSheetView<Country>.multi(
                items: countries,
                initialSelection: embeddedCountries,
                title: 'Build your shortlist',
                searchable: true,
                searchHintText: 'Search countries',
                itemLabelBuilder: (country) => country.name,
                itemKeyBuilder: (country) => country.code,
                sectionBuilder: (country) => country.region,
                onSelectionChanged: (selection) {
                  setState(() => embeddedCountries = selection);
                },
                onConfirmed: (selection) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${selection.length} countries confirmed',
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectOne() async {
    final result = await SelectionSheet.showSingle<Country>(
      context: context,
      item: SelectionSheetViewItem(
        items: countries,
        initialValue: modalCountry,
        title: 'Country',
        hintText: 'Search countries',
      ),
      searchable: true,
      itemLabelBuilder: (country) => country.name,
      itemKeyBuilder: (country) => country.code,
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

    if (result != null) setState(() => modalCountry = result);
  }

  Future<void> _selectRemotely() async {
    final result = await SelectionSheet.showMulti<Country>(
      context: context,
      item: SelectionSheetViewItem(
        loadItems: _loadCountries,
        pageSize: 16,
        initialSelection: remoteCountries,
        hintText: 'Search the remote source',
        title: 'Remote countries',
      ),
      searchable: true,
      itemLabelBuilder: (country) => country.name,
      itemKeyBuilder: (country) => country.code,
      sectionBuilder: (country) => country.region,
      layout: SelectionSheetLayout.grid,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, country, state) {
        return Card(
          color: state.isSelected
              ? Theme.of(context).colorScheme.secondaryContainer
              : null,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                '${country.code}  ${country.name}',
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );

    if (result != null) setState(() => remoteCountries = result);
  }

  Future<SelectionSheetPage<Country>> _loadCountries(
    SelectionSheetLoadRequest request,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    request.cancellationToken.throwIfCancelled();

    final query = request.query.toLowerCase();
    final matches = countries.where((country) {
      return country.name.toLowerCase().contains(query);
    }).toList();
    final start = (request.page - 1) * request.pageSize;
    if (start >= matches.length) {
      return const SelectionSheetPage(items: []);
    }

    final end = (start + request.pageSize).clamp(0, matches.length);
    return SelectionSheetPage(
      // Fresh instances demonstrate why itemKeyBuilder is preferable to
      // relying on object identity for remote data.
      items: [
        for (final country in matches.sublist(start, end))
          Country(country.code, country.name, country.region),
      ],
      hasMore: end < matches.length,
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Production-ready selection workflows',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Explore local and remote search, pagination, sections, grid '
              'layout, forms, custom presentation, and embedded views.',
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String description;
  final Widget child;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (badge case final label?)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(label),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(description),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class Country {
  const Country(this.code, this.name, this.region);

  final String code;
  final String name;
  final String region;
}
