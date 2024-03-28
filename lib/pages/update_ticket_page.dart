import 'package:flutter/material.dart';
import 'package:help_desk/database/firestore.dart';

class UpdateTicketPage extends StatefulWidget {
  final bool isAdmin;
  final String ticketId;
  final String currentTitle;
  final String currentPriority;
  final String currentDescription;
  final String currentStatus;

  const UpdateTicketPage({
    Key? key,
    required this.isAdmin,
    required this.ticketId,
    required this.currentTitle,
    required this.currentPriority,
    required this.currentDescription,
    required this.currentStatus,
  }) : super(key: key);

  @override
  State<UpdateTicketPage> createState() => _UpdateTicketPageState();
}

class _UpdateTicketPageState extends State<UpdateTicketPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreDatabase database = FirestoreDatabase();

  late String _title;
  late String _priority;
  late String _description;
  String _status = 'Not Started';

  @override
  void initState() {
    super.initState();
    _title = widget.currentTitle;
    _priority = widget.currentPriority;
    _description = widget.currentDescription;
    _status = widget.currentStatus;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          "Update Ticket",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) {
                  _title = value!;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _priority,
                items: const [
                  DropdownMenuItem(
                    value: 'Low',
                    child: Text('Low'),
                  ),
                  DropdownMenuItem(
                    value: 'Medium',
                    child: Text('Medium'),
                  ),
                  DropdownMenuItem(
                    value: 'High',
                    child: Text('High'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 16.0),
              const Text('Description'),
              SizedBox(
                height: 6 * 24.0,
                child: TextFormField(
                  initialValue: _description,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Enter description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _description = value!;
                  },
                ),
              ),
              if (widget.isAdmin) ...[
                const SizedBox(height: 16.0),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: _status,
                  items: const [
                    'Not Started',
                    'In Progress',
                    'Completed',
                    'Deleted',
                    'Deferred',
                    'Waiting on CSR'
                  ]
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
              ],
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _updateTicket(context);
                    },
                    child: Text(
                      'Update Ticket',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, 'cancel');
                    },
                    child: Text(
                      'cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _updateTicket(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Implement update ticket functionality using FirestoreDatabase
      await database.updateTicket(
        widget.ticketId,
        _title,
        _priority,
        _description,
        status: _status,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ticket updated successfully")),
      );
      Navigator.pop(context); // Go back to the previous page after updating
    }
  }
}
