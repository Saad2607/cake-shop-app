class SavedAddress {
  final String id;
  final String label;
  final String fullAddress;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as String,
      label: json['label'] as String,
      fullAddress: json['fullAddress'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'fullAddress': fullAddress,
      };

  static const presetLabels = ['Home', 'Office', 'Other'];
}
