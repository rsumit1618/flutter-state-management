enum NoteSource {
  bloc,
  getx,
  riverpod,
  api;

  static NoteSource fromStorage(String value) {
    try {
      return NoteSource.values.firstWhere((source) => source.name == value);
    } on StateError {
      throw FormatException('Unknown note source: $value');
    }
  }
}

class NoteModel {
  final int? id;
  final String title;
  final String description;
  final NoteSource source;

  const NoteModel({
    this.id,
    required this.title,
    required this.description,
    required this.source,
  });

  NoteModel copyWith({
    int? id,
    String? title,
    String? description,
    NoteSource? source,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      source: source ?? this.source,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'source': source.name,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      source: NoteSource.fromStorage(map['source'] as String),
    );
  }

  factory NoteModel.fromApiJson(Map<String, dynamic> json) {
    return NoteModel(
      id: null,
      title: json['title'].toString(),
      description: json['body'].toString(),
      source: NoteSource.api,
    );
  }
}
