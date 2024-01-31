import 'dart:math';

double log10(num x) => log(x) / ln10;

double calculateYAxisStepInterval(double minValue, double maxValue, double desiredStep) {
  double range = maxValue - minValue;

  if (range == 0) {
    // If the range is zero, handle this case to prevent division by zero.
    return desiredStep;
  }

  // Calculate the order of magnitude of the range
  double magnitude;
  if (range == 0) {
    magnitude = 0;
  } else {
    // magnitude = (range.abs() / 10).log10().floorToDouble();
    magnitude = log10(range.abs() / 10).floorToDouble();
  }

  // Determine the divisor based on the magnitude
  double divisor = 1;
  if (magnitude < 3) {
    // If the magnitude is less than 3 (e.g., 100 or 1,000), use 100 as the divisor
    divisor = 100;
  } else {
    // If the magnitude is 3 or more (e.g., 10,000 or 100,000), use 1,000 as the divisor
    divisor = 1000;
  }

  // Calculate the step value by rounding up to the nearest desired step value
  double step = (range / divisor).ceilToDouble() * desiredStep / 100;

  return step;
}

double getMagnitude({required double value}) {
  if (value == 0) return 0;
  double base = 10;

  // Calculate the logarithm of the number with respect to the base
  double logValue = log(value) / log(base);

  // Round the logValue to the nearest integer to get the magnitude
  final magnitude = logValue.floor();
  return pow(base, magnitude).toDouble();
}
