class ExtractedDocumentData {
  final String? fullName;
  final String? nationalId;
  final String? passportNumber;
  final String? nationality;
  final DateTime? birthDate;
  final String? address;
  final DateTime? passportIssueDate;
  final DateTime? passportExpiryDate;
  final String? gender;

  const ExtractedDocumentData({
    this.fullName,
    this.nationalId,
    this.passportNumber,
    this.nationality,
    this.birthDate,
    this.address,
    this.passportIssueDate,
    this.passportExpiryDate,
    this.gender,
  });

  factory ExtractedDocumentData.empty() {
    return const ExtractedDocumentData();
  }

  ExtractedDocumentData copyWith({
    String? fullName,
    String? nationalId,
    String? passportNumber,
    String? nationality,
    DateTime? birthDate,
    String? address,
    DateTime? passportIssueDate,
    DateTime? passportExpiryDate,
    String? gender,
  }) {
    return ExtractedDocumentData(
      fullName: fullName ?? this.fullName,
      nationalId: nationalId ?? this.nationalId,
      passportNumber: passportNumber ?? this.passportNumber,
      nationality: nationality ?? this.nationality,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      passportIssueDate: passportIssueDate ?? this.passportIssueDate,
      passportExpiryDate: passportExpiryDate ?? this.passportExpiryDate,
      gender: gender ?? this.gender,
    );
  }
}
