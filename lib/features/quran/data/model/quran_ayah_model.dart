class QuranAyahModel {
  final int number;
  final String text;

  const QuranAyahModel({required this.number, required this.text});

  factory QuranAyahModel.fromXml(Map<String, String> attributes) {
    return QuranAyahModel(
      number: int.parse(attributes['index']!),
      text: attributes['text']!,
    );
  }
}
