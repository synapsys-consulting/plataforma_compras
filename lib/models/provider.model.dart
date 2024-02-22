
class Provider {
  Provider({
    required this.personeName
  });
  final String personeName;
  factory Provider.fromJson (Map<String, dynamic> json) {
    return Provider (
        personeName: json['PERSONE_NAME']
    );
  }
}