import 'dart:async';
import 'package:dataspikemobilesdk/data/models/request/country_request_body.dart';
import 'package:flutter/foundation.dart';
import 'package:dataspikemobilesdk/domain/models/country_domain_model.dart';
import '/dependencies_provider/dataspike_injector.dart';
import 'package:dataspikemobilesdk/data/use_cases/set_country_use_case.dart';

class CountryPickerViewModel extends ChangeNotifier {
  final List<CountryDomainModel> _all;
  List<CountryDomainModel> _filtered;
  String _query = '';
  Timer? _debounce;

  final SetCountryUseCase setCountryUseCase;

  CountryPickerViewModel({required this.setCountryUseCase})
      : _all = List.of(DataspikeInjector.component.verificationManager.countries),
        _filtered = const [] {
    _all.sort((a, b) => a.name.compareTo(b.name));
    _filtered = List.of(_all);
  }

  List<CountryDomainModel> get countries => _filtered;
  bool get isEmptyData => _all.isEmpty;
  String get query => _query;

  void setQuery(String value) {
    final q = value.trim().toLowerCase();
    if (q == _query) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      _query = q;
      if (_query.isEmpty) {
        _filtered = _all;
      } else {
        _filtered =
            _all.where((c) => c.name.toLowerCase().contains(_query)).toList();
      }
      notifyListeners();
    });
  }

  void setCountry(CountryDomainModel country) {
    setCountryUseCase.call(CountryRequestBody(country: country.alphaTwo));
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}