import 'package:flutter/material.dart';
import 'item.dart';

class AddItemBottomSheet extends StatefulWidget {
  AddItemBottomSheet({Key? key, this.item}) : super(key: key);

  final Item? item;

  @override
  AddItemBottomSheetState createState() => AddItemBottomSheetState();
}

class AddItemBottomSheetState extends State<AddItemBottomSheet> {
  Item item = Item();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) item.update(widget.item!);
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 8.0, left: 16.0, right: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(autofocus: true, onChanged: (val) => setState(() => item.label = val)),
            const SizedBox(height: 24.0),
            Text('Repeats on', style: Theme.of(context).textTheme.subtitle2),
            const SizedBox(height: 8.0),
            WeekSelector(
              value: item.repeat,
              onChanged: () => setState(() {}),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Done'),
                  onPressed: item.label.isEmpty ? null : () => Navigator.of(context).pop(item),
                ),
              ],
            ),
          ],
        ),
      );
}

class WeekSelector extends StatelessWidget {
  WeekSelector({Key? key, required this.value, required this.onChanged}) : super(key: key);

  final Set<int> value;
  final VoidCallback onChanged;
  final List<String> labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext build) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 4.0),
          for (var i in [7, 1, 2, 3, 4, 5, 6])
            InputChip(
              selected: value.contains(i),
              onSelected: (selected) {
                if (selected)
                  value.add(i);
                else
                  value.remove(i);
                onChanged();
              },
              showCheckmark: false,
              label: Text(labels[i - 1]),
              shape: CircleBorder(),
              visualDensity: VisualDensity(horizontal: -2.0, vertical: 0.0),
            ),
        ],
      );
}
