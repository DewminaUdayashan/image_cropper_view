/// Defines the aspect ratio for cropping.
enum CropperRatio {
  /// Maintains the original aspect ratio of the image.
  original(1.0, 'Original'),

  /// A square aspect ratio (1:1).
  ratio1_1(1.0, '1:1'),

  /// A 3:4 aspect ratio.
  ratio3_4(3 / 4, '3:4'),

  /// A 4:3 aspect ratio.
  ratio4_3(4 / 3, '4:3'),

  /// A 16:9 aspect ratio.
  ratio16_9(16 / 9, '16:9'),

  /// A 9:16 aspect ratio.
  ratio9_16(9 / 16, '9:16'),

  /// Allows for a custom or free-form cropping ratio.
  custom(null, 'Custom');

  /// Creates a [CropperRatio] with a numeric [ratio] value and a display [label].
  const CropperRatio(this.ratio, this.label);

  /// The numeric value of the aspect ratio (width / height).
  ///
  /// If null, it indicates a free-form crop where the user can adjust dimensions independently.
  final double? ratio;

  /// A human-readable label for the aspect ratio.
  final String label;
}
