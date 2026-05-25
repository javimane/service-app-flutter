class ProfessionalAvailabilityModel {
  final int id;
  final int professionalId;
  final int? dayOfWeek;
  final String startTime;
  final String endTime;

  ProfessionalAvailabilityModel({
    required this.id,
    required this.professionalId,
    this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory ProfessionalAvailabilityModel.fromJson(Map<String, dynamic> json) =>
      ProfessionalAvailabilityModel(
        id: json['id'] as int,
        professionalId: json['professional_id'] as int,
        dayOfWeek: json['day_of_week'] as int?,
        startTime: json['start_time'] as String? ?? '',
        endTime: json['end_time'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'professional_id': professionalId,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
      };
}
