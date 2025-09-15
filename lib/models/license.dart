
class License {
  final String key;
  final DateTime expirationDate;

  License({required this.key, required this.expirationDate});

  factory License.fromMap(Map<String, dynamic> map) {
    return License(
      key: map['key'],
      expirationDate: map['expirationDate'].toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'expirationDate': expirationDate,
    };
  }
}
