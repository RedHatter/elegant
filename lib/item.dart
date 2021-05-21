extension DateTimeComparison on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

class Item {
  Item({this.label = '', this.repeat = const {1, 2, 3, 4, 5, 6, 7}});

  Item.fromJson(Map<String, dynamic> json)
      : label = json['label'],
        _checked = json['checked'] is int ? DateTime.fromMillisecondsSinceEpoch(json['checked']) : null,
        repeat = Set.unmodifiable(json['repeat'].cast<int>());

  String label;
  Set<int> repeat;

  DateTime? _checked;
  bool get checked => _checked != null && _checked!.isToday;
  set checked(bool val) => _checked = val ? DateTime.now() : null;

  void update(Item item) => this
    ..label = item.label
    ..repeat = item.repeat;

  Map<String, dynamic> toJson() => {
        'label': label,
        'checked': _checked?.millisecondsSinceEpoch,
        'repeat': repeat.toList(),
      };
}
