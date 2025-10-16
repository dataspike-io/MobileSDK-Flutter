import 'package:dataspikemobilesdk/view/ui/loader.dart';
import 'package:dataspikemobilesdk/view/ui/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:dataspikemobilesdk/res/colors/app_colors.dart';
import 'package:dataspikemobilesdk/view_models/countries_view_model.dart';
import 'package:dataspikemobilesdk/view_models/factory/dataspike_view_model_factory.dart';

class CountryPickerScreen extends StatefulWidget {
  final String title;
  final ValueChanged<String>? onCountrySelected;

  const CountryPickerScreen({
    super.key,
    required this.title,
    this.onCountrySelected,
  });

  @override
  State<CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends State<CountryPickerScreen> {
  final _searchCtrl = TextEditingController();
  late final CountryPickerViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = DataspikeViewModelFactory().create<CountryPickerViewModel>();
    _searchCtrl.addListener(() => _vm.setQuery(_searchCtrl.text));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              TopBar(hasTimer: false, isShowingWarningPopup: false),
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
              AnimatedBuilder(
                animation: _vm,
                builder: (_, __) {
                  if (_vm.isEmptyData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: const TextStyle(
                        color: AppColors.darkIndigo,
                        fontSize: 14,
                        fontFamily: 'Figtree',
                        fontWeight: FontWeight.w500,
                        package: 'dataspikemobilesdk',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by country name',
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.palePeriwinkle,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.palePeriwinkle,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: AppColors.palePeriwinkle,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              Expanded(
                child: AnimatedBuilder(
                  animation: _vm,
                  builder: (_, __) {
                    if (_vm.isEmptyData) {
                      return const Center(
                        child: Loader(color: AppColors.slateGray),
                      );
                    }
                    final list = _vm.countries;
                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final c = list[i];
                        final alpha = c.alphaTwo.toLowerCase();
                        final name = c.name.trim();
                        return InkWell(
                          key: ValueKey(alpha),
                          onTap: name.isEmpty
                              ? null
                              : () {
                                  if (widget.onCountrySelected != null) {
                                    widget.onCountrySelected?.call(name);
                                  } else {
                                    _vm.setCountry(c);
                                  }
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
                                      color: AppColors.darkIndigo,
                                      fontFamily: 'FunnelDisplay',
                                      package: 'dataspikemobilesdk',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, indent: 24, endIndent: 24),
                    );
                  },
                ),
              ),
            ],
          ),
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
