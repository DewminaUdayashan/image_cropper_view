enum CropperRatio {
  original(1.0, 'Original'),
  ratio1_1(1.0, '1:1'),
  ratio3_4(3 / 4, '3:4'),
  ratio4_3(4 / 3, '4:3'),
  ratio16_9(16 / 9, '16:9'),
  ratio9_16(9 / 16, '9:16'),
  custom(null, 'Custom');

  const CropperRatio(this.ratio, this.label);

  final double? ratio;
  final String label;
}
