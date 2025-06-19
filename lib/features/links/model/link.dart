class Link {
  final String id;
  final String title;
  final String url;
  final String type; // Ex: Instagram, YouTube, Facebook

  Link({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
  });

  Link copyWith({String? id, String? title, String? url, String? type}) {
    return Link(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'url': url, 'type': type};
  }

  factory Link.fromMap(Map<String, dynamic> map) {
    return Link(
      id: map['id'],
      title: map['title'],
      url: map['url'],
      type: map['type'],
    );
  }
}
