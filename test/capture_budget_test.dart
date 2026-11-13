import 'package:dataspikemobilesdk/domain/managers/capture_budget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CaptureBudget newBudget() => CaptureBudget(
    baseTimeout: const Duration(seconds: 8),
    maxTimeout: const Duration(seconds: 20),
    photosToSend: 4,
    spareCandidates: 2,
    frameGap: const Duration(milliseconds: 300),
  );

  test('uses the base timeout before anything was measured', () {
    expect(newBudget().timeout, const Duration(seconds: 8));
  });

  test('a fast device keeps the base timeout', () {
    final budget = newBudget()
      ..recordValidation(const Duration(milliseconds: 300))
      ..recordValidation(const Duration(milliseconds: 500));

    // (400 ms + 300 ms) * 6 = 4.2 s, below the 8 s floor.
    expect(budget.timeout, const Duration(seconds: 8));
  });

  test('a slow device gets time for every photo plus spare candidates', () {
    final budget = newBudget()..recordValidation(const Duration(seconds: 2));

    // (2 s + 300 ms) * 6 = 13.8 s, so four 2 s validations fit.
    expect(budget.timeout, const Duration(milliseconds: 13800));
  });

  test('the budget follows the average, not a single warm-up outlier', () {
    final budget = newBudget()
      ..recordValidation(const Duration(seconds: 4))
      ..recordValidation(const Duration(seconds: 1))
      ..recordValidation(const Duration(seconds: 1));

    // Average 2 s: (2 s + 300 ms) * 6 = 13.8 s.
    expect(budget.timeout, const Duration(milliseconds: 13800));
  });

  test('is capped so a hopeless capture still ends', () {
    final budget = newBudget()..recordValidation(const Duration(seconds: 9));

    expect(budget.timeout, const Duration(seconds: 20));
  });
}
