import 'package:dataspikemobilesdk/view/ui/loader.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/domain/models/country_domain_model.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'dart:async';

class CountryPickerScreen extends StatefulWidget {
  final String title;
  final String? initialAlphaTwo;
  final ValueChanged<String>? onCountrySelected;

  const CountryPickerScreen({
    super.key,
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
  List<CountryDomainModel> _filtered = [];
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _all = DataspikeInjector.component.verificationManager.countries;
    _all.sort((a, b) => (a.name).compareTo(b.name));
    _filtered = List.of(_all);

    _searchCtrl.addListener(() {
      final text = _searchCtrl.text.trim().toLowerCase();
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 150), () {
        if (!mounted) return;
        setState(() {
          _query = text;
          if (_query.isEmpty) {
            _filtered = _all;
          } else {
            _filtered = _all
                .where((c) => (c.name).toLowerCase().contains(_query))
                .toList();
          }
        });
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            TopBar(hasTimer: false),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontFamily: 'FunnelDisplay',
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                    package: 'dataspikemobilesdk',
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
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'FunnelDisplay',
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      package: 'dataspikemobilesdk',
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: TextField(
                  style: const TextStyle(
                    color: AppColors.darkIndigo,
                    fontSize: 14,
                    fontFamily: 'Figtree',
                    fontWeight: FontWeight.w500,
                    package: 'dataspikemobilesdk',
                  ),
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Search by country name',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.palePeriwinkle),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.palePeriwinkle),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: AppColors.palePeriwinkle),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Expanded(
              child: _all.isEmpty
                  ? const Center(child: Loader(color: AppColors.slateGray))
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemBuilder: (_, i) {
                        final c = _filtered[i];
                        final alpha = (c.alphaTwo).toLowerCase();
                        final selected =
                            widget.initialAlphaTwo?.toLowerCase() == alpha;
                        final name = (c.name).trim();
                        return InkWell(
                          key: ValueKey(alpha),
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
                                      fontSize: 28,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? AppColors.royalPurple
                                          : AppColors.darkIndigo,
                                      fontFamily: 'FunnelDisplay',
                                      package: 'dataspikemobilesdk',
                                    ),
                                  ),
                                ),
                                if (selected)
                                  const Icon(
                                    Icons.check,
                                    color: AppColors.royalPurple,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 24, endIndent: 24),
                      itemCount: _filtered.length,
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
        cacheWidth: 24,  
        cacheHeight: 18,
        gaplessPlayback: true,
        filterQuality: FilterQuality.none,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox(width: 26, height: 18),
      ),
    );
  }
}
