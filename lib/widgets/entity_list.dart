import 'package:flutter/material.dart';

class EntityList<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T) getTitle;
  final String Function(T) getSubtitle;
  final void Function(T) onEdit;
  final void Function(T) onDelete;
  final void Function(T)? onTap; // ✅ Added optional onTap

  const EntityList({
    super.key,
    required this.items,
    required this.getTitle,
    required this.getSubtitle,
    required this.onEdit,
    required this.onDelete,
    this.onTap, // ✅ allow optional
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (ctx, i) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: ListTile(
          title: Text(getTitle(items[i])),
          subtitle: Text(getSubtitle(items[i])),
          onTap: onTap != null ? () => onTap!(items[i]) : null, // ✅ handle safely
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => onEdit(items[i]),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => onDelete(items[i]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
