extension DataConversion on int? {
  String toTemperature() {
    if (this == null) {
      return '?';
    }
    // Из полученных данных выводим температуру
    final temperature = (this! * 200.00 / 1048576.00) - 50.00;
    if (temperature > 0) {
      return '+${temperature.toStringAsFixed(1)} \u00BAC';
    }
    return '${temperature.toStringAsFixed(1)} \u00BAC';
  }

  String toHumidity() {
    if (this == null) {
      return '?';
    }
    // Из полученных данных выводим относительную влажность
    final humidity = this! * 100.00 / 1048576.00;
    return '${humidity.toStringAsFixed(1)} %';
  }
}
