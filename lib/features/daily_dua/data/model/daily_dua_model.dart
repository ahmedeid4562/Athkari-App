class DailyDuaModel {
  final int id;
  final String title;
  final String text;
  final String reference;

  const DailyDuaModel({
    required this.id,
    required this.title,
    required this.text,
    required this.reference,
  });

  factory DailyDuaModel.fromJson(Map<String, dynamic> json) {
    return DailyDuaModel(
      id: json['id'] as int,
      title: json['title'] as String,
      text: json['text'] as String,
      reference: json['reference'] as String,
    );
  }
}
