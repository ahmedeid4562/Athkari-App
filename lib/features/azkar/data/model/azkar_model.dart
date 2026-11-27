class AzkarModel {
  final int id;
  final String text;
  final int repeat;
  final String reference;

  const AzkarModel({
    required this.id,
    required this.text,
    required this.repeat,
    required this.reference,
  });

  factory AzkarModel.fromJson(Map<String, dynamic> json) {
    return AzkarModel(
      id: json['id'],
      text: json['text'],
      repeat: json['repeat'],
      reference: json['reference'],
    );
  }
}