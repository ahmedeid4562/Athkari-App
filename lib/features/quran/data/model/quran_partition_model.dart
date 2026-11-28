class QuranPartitionModel {
  final int index;
  final int surahNumber;
  final int ayahNumber;

  const QuranPartitionModel({
    required this.index,
    required this.surahNumber,
    required this.ayahNumber,
  });

  factory QuranPartitionModel.fromXml(Map<String, String> attributes) {
    return QuranPartitionModel(
      index: int.parse(attributes['index']!),
      surahNumber: int.parse(attributes['sura']!),
      ayahNumber: int.parse(attributes['aya']!),
    );
  }
}
