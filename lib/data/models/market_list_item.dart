class MarketListItem {
  final String id;
  final String text;
  final bool isChecked;

  MarketListItem({
    required this.id,
    required this.text,
    this.isChecked = false,
  });

  MarketListItem copyWith({
    String? id,
    String? text,
    bool? isChecked,
  }) =>
      MarketListItem(
        id: id ?? this.id,
        text: text ?? this.text,
        isChecked: isChecked ?? this.isChecked,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'isChecked': isChecked,
      };

  factory MarketListItem.fromMap(Map<String, dynamic> m) => MarketListItem(
        id: m['id'] as String,
        text: m['text'] as String,
        isChecked: m['isChecked'] as bool? ?? false,
      );
}
