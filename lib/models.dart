class Bird {
  String id;
  String name;
  String kind;
  String color;
  String sex;
  String ring;
  String cv;
  String? fatherId;
  String? motherId;
  DateTime bornOn;
  DateTime? lastPhotoAt;
  DateTime? nextPhotoDue;
  List<String> photos;
  List<String> photoLog;
  bool reminders;

  Bird({
    required this.id,
    required this.name,
    this.kind = '',
    this.color = '',
    this.sex = 'ذكر',
    this.ring = '',
    this.cv = '',
    this.fatherId,
    this.motherId,
    DateTime? bornOn,
    this.lastPhotoAt,
    this.nextPhotoDue,
    List<String>? photos,
    List<String>? photoLog,
    this.reminders = true,
  })  : bornOn = bornOn ?? DateTime.now(),
        photos = photos ?? <String>[],
        photoLog = photoLog ?? <String>[];

  bool get isDue {
    if (!reminders || nextPhotoDue == null) return false;
    return !nextPhotoDue!.isAfter(DateTime.now());
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'kind': kind,
        'color': color,
        'sex': sex,
        'ring': ring,
        'cv': cv,
        'fatherId': fatherId,
        'motherId': motherId,
        'bornOn': bornOn.toIso8601String(),
        'lastPhotoAt': lastPhotoAt?.toIso8601String(),
        'nextPhotoDue': nextPhotoDue?.toIso8601String(),
        'photos': photos,
        'photoLog': photoLog,
        'reminders': reminders,
      };

  factory Bird.fromJson(Map<String, dynamic> json) {
    return Bird(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      kind: (json['kind'] ?? '').toString(),
      color: (json['color'] ?? '').toString(),
      sex: (json['sex'] ?? 'ذكر').toString(),
      ring: (json['ring'] ?? '').toString(),
      cv: (json['cv'] ?? '').toString(),
      fatherId: json['fatherId']?.toString(),
      motherId: json['motherId']?.toString(),
      bornOn: _parseDate(json['bornOn']) ?? DateTime.now(),
      lastPhotoAt: _parseDate(json['lastPhotoAt']),
      nextPhotoDue: _parseDate(json['nextPhotoDue']),
      photos: _stringList(json['photos']),
      photoLog: _stringList(json['photoLog']),
      reminders: json['reminders'] != false,
    );
  }

  Bird copyWith({
    String? name,
    String? kind,
    String? color,
    String? sex,
    String? ring,
    String? cv,
    String? fatherId,
    String? motherId,
    DateTime? bornOn,
    DateTime? lastPhotoAt,
    DateTime? nextPhotoDue,
    List<String>? photos,
    List<String>? photoLog,
    bool? reminders,
  }) {
    return Bird(
      id: id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      color: color ?? this.color,
      sex: sex ?? this.sex,
      ring: ring ?? this.ring,
      cv: cv ?? this.cv,
      fatherId: fatherId ?? this.fatherId,
      motherId: motherId ?? this.motherId,
      bornOn: bornOn ?? this.bornOn,
      lastPhotoAt: lastPhotoAt ?? this.lastPhotoAt,
      nextPhotoDue: nextPhotoDue ?? this.nextPhotoDue,
      photos: photos ?? this.photos,
      photoLog: photoLog ?? this.photoLog,
      reminders: reminders ?? this.reminders,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((e) => e.toString()).toList();
  }
}

String formatDate(DateTime? date) {
  if (date == null) return '—';
  final d = DateTime(date.year, date.month, date.day);
  return '${d.day}/${d.month}/${d.year}';
}

String formatDateTime(DateTime? date) {
  if (date == null) return '—';
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '${formatDate(date)} $h:$m';
}
