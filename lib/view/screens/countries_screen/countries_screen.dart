import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/domain/models/country_domain_model.dart';
import '/dependencies_provider/dataspike_injector.dart';

class CountryPickerScreen extends StatefulWidget {
  final String title;
  final String? initialAlphaTwo;
  final ValueChanged<String>? onCountrySelected; 

  const CountryPickerScreen({super.key, 
    required this.title,
    this.initialAlphaTwo,
    this.onCountrySelected,
  });

  @override
  State<CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends State<CountryPickerScreen> {
  final _searchCtrl = TextEditingController();
  late List<CountryDomainModel> _all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _all = DataspikeInjector.component.verificationManager.checks.countries;
    _searchCtrl.addListener(() {
      setState(() {
        _query = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _all.where((c) {
      if (_query.isEmpty) return true;
      final name = (c.name).toLowerCase();
      return name.contains(_query);
    }).toList()
      ..sort((a, b) => (a.name).compareTo(b.name));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            TopBar(timer: null),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            if (_all.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'No countries loaded',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by country name',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: _all.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        final alpha = (c.alphaTwo).toLowerCase();
                        final selected =
                            widget.initialAlphaTwo?.toLowerCase() == alpha;
                        final name = (c.name).trim();
                        return InkWell(
                          onTap: name.isEmpty
                              ? null
                              : () {
                                  widget.onCountrySelected?.call(name); 
                                  Navigator.of(context).pop(name);
                                },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
                            child: Row(
                              children: [
                                _FlagNetwork(code: alpha),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? AppColors.accent
                                          : AppColors.darkGrey,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(Icons.check,
                                      color: AppColors.accent, size: 20),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                        indent: 24,
                        endIndent: 24,
                      ),
                      itemCount: filtered.length,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlagNetwork extends StatelessWidget {
  final String code;
  const _FlagNetwork({required this.code});

  @override
  Widget build(BuildContext context) {
    if (code.length != 2) {
      return const SizedBox(width: 26, height: 18);
    }
    final url = 'https://flagcdn.com/80x60/$code.png';
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: Image.network(
        url,
        width: 24,
        height: 18,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const SizedBox(width: 26, height: 18),
      ),
    );
  }
}