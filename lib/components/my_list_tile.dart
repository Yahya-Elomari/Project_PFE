import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;
  final Function(DismissDirection) onDismissed;
  final Key? key;

  const MyListTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onDismissed,
    this.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Dismissible(
          key: key ?? UniqueKey(),
          direction: DismissDirection.horizontal,
          background: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20.0),
            child: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
          secondaryBackground: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          onDismissed: onDismissed,
          child: ListTile(
            title: Text(title),
            subtitle: Text(
              subtitle,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            trailing: Text(trailing),
          ),
        ),
      ),
    );
  }
}
