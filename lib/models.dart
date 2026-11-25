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

  factory Bird.fromJson(Map<String, dynamic> json) => Bird(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        kind: (json['kind'] ?? '').toString(),
        color: (json['color'] ?? '').toString(),
        sex: (json['sex'] ?? 'ذكر').toString(),
        ring: (json['ring'] ?? '').toString(),
        cv: (json['cv'] ?? '').toString(),
        fatherId: json['fatherId']?.toString(),
        motherId: json['motherId']?.toString(),
        bornOn: _date(json['bornOn']) ?? DateTime.now(),
        lastPhotoAt: _date(json['lastPhotoAt']),
        nextPhotoDue: _date(json['nextPhotoDue']),
        photos: _list(json['photos']),
        photoLog: _list(json['photoLog']),
        reminders: json['reminders'] != false,
      );

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
  }) =>
      Bird(
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

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  static List<String> _list(dynamic value) => value is List
      ? value.map((e) => e.toString()).toList()
      : <String>[];
}

class Clutch {
  String id;
  String motherId;
  String fatherId;
  DateTime laidOn;
  DateTime hatchDue;
  int eggsCount;
  int hatchedCount;
  String status;
  String note;

  Clutch({
    required this.id,
    required this.motherId,
    this.fatherId = '',
    DateTime? laidOn,
    DateTime? hatchDue,
    this.eggsCount = 0,
    this.hatchedCount = 0,
    this.status = 'incubating',
    this.note = '',
  })  : laidOn = laidOn ?? DateTime.now(),
        hatchDue = hatchDue ?? DateTime.now().add(const Duration(days: 18));

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'motherId': motherId,
        'fatherId': fatherId,
        'laidOn': laidOn.toIso8601String(),
        'hatchDue': hatchDue.toIso8601String(),
        'eggsCount': eggsCount,
        'hatchedCount': hatchedCount,
        'status': status,
        'note': note,
      };

  factory Clutch.fromJson(Map<String, dynamic> json) => Clutch(
        id: (json['id'] ?? '').toString(),
        motherId: (json['motherId'] ?? '').toString(),
        fatherId: (json['fatherId'] ?? '').toString(),
        laidOn: _date(json['laidOn']) ?? DateTime.now(),
        hatchDue: _date(json['hatchDue']) ?? DateTime.now(),
        eggsCount: int.tryParse(json['eggsCount']?.toString() ?? '') ?? 0,
        hatchedCount: int.tryParse(json['hatchedCount']?.toString() ?? '') ?? 0,
        status: (json['status'] ?? 'incubating').toString(),
        note: (json['note'] ?? '').toString(),
      );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class Expense {
  String id;
  DateTime date;
  String category;
  double amount;
  String note;

  Expense({
    required this.id,
    DateTime? date,
    this.category = 'feed',
    this.amount = 0,
    this.note = '',
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'date': date.toIso8601String(),
        'category': category,
        'amount': amount,
        'note': note,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: (json['id'] ?? '').toString(),
        date: _date(json['date']) ?? DateTime.now(),
        category: (json['category'] ?? 'feed').toString(),
        amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
        note: (json['note'] ?? '').toString(),
      );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class FeedItem {
  String id;
  String name;
  double quantity;
  double threshold;

  FeedItem({
    required this.id,
    required this.name,
    this.quantity = 0,
    this.threshold = 5,
  });

  bool get isLow => quantity <= threshold;

  FeedItem copyWith({String? name, double? quantity, double? threshold}) =>
      FeedItem(
        id: id,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        threshold: threshold ?? this.threshold,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'quantity': quantity,
        'threshold': threshold,
      };

  factory FeedItem.fromJson(Map<String, dynamic> json) => FeedItem(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        quantity: double.tryParse(json['quantity']?.toString() ?? '') ?? 0,
        threshold: double.tryParse(json['threshold']?.toString() ?? '') ?? 5,
      );
}

class HealthRecord {
  String id;
  String birdId;
  DateTime date;
  String type;
  String note;
  DateTime? nextDue;

  HealthRecord({
    required this.id,
    required this.birdId,
    DateTime? date,
    this.type = 'treatment',
    this.note = '',
    this.nextDue,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'birdId': birdId,
        'date': date.toIso8601String(),
        'type': type,
        'note': note,
        'nextDue': nextDue?.toIso8601String(),
      };

  factory HealthRecord.fromJson(Map<String, dynamic> json) => HealthRecord(
        id: (json['id'] ?? '').toString(),
        birdId: (json['birdId'] ?? '').toString(),
        date: _date(json['date']) ?? DateTime.now(),
        type: (json['type'] ?? 'treatment').toString(),
        note: (json['note'] ?? '').toString(),
        nextDue: _date(json['nextDue']),
      );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

class WeightRecord {
  String id;
  String birdId;
  DateTime date;
  double grams;

  WeightRecord({
    required this.id,
    required this.birdId,
    DateTime? date,
    this.grams = 0,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'birdId': birdId,
        'date': date.toIso8601String(),
        'grams': grams,
      };

  factory WeightRecord.fromJson(Map<String, dynamic> json) => WeightRecord(
        id: (json['id'] ?? '').toString(),
        birdId: (json['birdId'] ?? '').toString(),
        date: _date(json['date']) ?? DateTime.now(),
        grams: double.tryParse(json['grams']?.toString() ?? '') ?? 0,
      );

  static DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}

String formatDate(DateTime? date) {
  if (date == null) return '—';
  return '${date.day}/${date.month}/${date.year}';
}

String formatDateTime(DateTime? date) {
  if (date == null) return '—';
  final h = date.hour.toString().padLeft(2, '0');
  final m = date.minute.toString().padLeft(2, '0');
  return '${formatDate(date)} $h:$m';
}

/// معامل القرابة (coancestry) بين طيرين عبر الأب والأم معاً.
double kinship(String? a, String? b, Map<String, Bird> byId) {
  final memo = <String, double>{};

  double calc(String? x, String? y, int depth) {
    if (x == null || y == null || depth > 8) return 0;
    if (x == y) return 1;
    final key = x.compareTo(y) <= 0 ? '$x|$y' : '$y|$x';
    final cached = memo[key];
    if (cached != null) return cached;
    final bx = byId[x];
    final by = byId[y];
    if (bx == null || by == null) return 0;
    if (bx.fatherId == null &&
        bx.motherId == null &&
        by.fatherId == null &&
        by.motherId == null) {
      return 0;
    }
    final value = 0.5 *
        (calc(bx.fatherId, y, depth + 1) +
            calc(bx.motherId, y, depth + 1) +
            calc(x, by.fatherId, depth + 1) +
            calc(x, by.motherId, depth + 1));
    memo[key] = value;
    return value;
  }

  return calc(a, b, 0);
}

/// معامل التزواج الداخلي للطير = قرابة أبويه ÷ ٢.
double inbreedingCoefficient(Bird bird, Map<String, Bird> byId) =>
    kinship(bird.fatherId, bird.motherId, byId) / 2;
