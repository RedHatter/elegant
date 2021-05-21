import 'package:flutter/material.dart';
import 'item.dart';

class ItemView extends StatelessWidget {
  ItemView(this.item, {Key? key, required this.onChanged, required this.onLongPress}) : super(key: key);

  final Item item;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext build) => GestureDetector(
        onTap: () => onChanged(!item.checked),
        onLongPress: onLongPress,
        behavior: HitTestBehavior.translucent,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 200),
          opacity: item.checked ? 0.6 : 1.0,
          child: Row(children: [
            Checkbox(value: item.checked, onChanged: onChanged, shape: CircleBorder()),
            Text(
              item.label,
              style: TextStyle(fontSize: 12.0),
            ),
          ]),
        ),
      );
}
