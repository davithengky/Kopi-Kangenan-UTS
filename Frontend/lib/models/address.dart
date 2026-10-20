/// Alamat pengiriman tersimpan (PRD F4).
class Address {
  final String id;
  final String label;
  final String recipient;
  final String phone;
  final String detail;

  /// Patokan, mis. "Samping masjid, pagar hitam".
  final String note;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.recipient,
    required this.phone,
    required this.detail,
    this.note = '',
    this.isDefault = false,
  });

  Address copyWith({
    String? label,
    String? recipient,
    String? phone,
    String? detail,
    String? note,
    bool? isDefault,
  }) {
    return Address(
      id: id,
      label: label ?? this.label,
      recipient: recipient ?? this.recipient,
      phone: phone ?? this.phone,
      detail: detail ?? this.detail,
      note: note ?? this.note,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
