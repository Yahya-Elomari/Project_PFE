import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_desk/components/my_list_tile.dart';
import 'package:help_desk/database/firestore.dart';
import 'package:help_desk/pages/create_ticket.dart';
import 'package:help_desk/pages/update_ticket_page.dart';

class TicketsListPage extends StatefulWidget {
  TicketsListPage({Key? key, required this.currentUser}) : super(key: key);
  final User? currentUser;

  @override
  State<TicketsListPage> createState() => _TicketsListPageState();
}

class _TicketsListPageState extends State<TicketsListPage> {
  int _selectedIndex = 0;
  bool isAdmin = false;
  List<QueryDocumentSnapshot<Object?>> tickets = [];
  late StreamSubscription<QuerySnapshot> _streamSubscription;

  Future<Map<String, dynamic>> filterTicketsByStatus(String status) async {
    final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
    bool isAdmin = false;
    List<QueryDocumentSnapshot<Object?>> filteredTickets = [];
    FirestoreDatabase database = FirestoreDatabase();

    if (currentUserEmail != null) {
      isAdmin = await database.isAdmin();
      final snapshot = await database.getTicketsStream().first;
      if (isAdmin) {
        filteredTickets = snapshot.docs
            .where((doc) =>
                (doc.data() as Map<String, dynamic>)['Status'] == status)
            .toList();
      } else {
        filteredTickets = snapshot.docs
            .where((doc) =>
                (doc.data() as Map<String, dynamic>)['UserEmail'] ==
                currentUserEmail)
            .toList();
      }
    }

    return {'isAdmin': isAdmin, 'filteredTickets': filteredTickets};
  }

  void checkUserRole() async {
    if (widget.currentUser != null) {
      final isAdminUser = await FirestoreDatabase().isAdmin();
      setState(() {
        isAdmin = isAdminUser;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    checkUserRole();
    _streamSubscription =
        FirestoreDatabase().getTicketsStream().listen((snapshot) {
      _refreshTicketList();
    });
  }

  @override
  void dispose() {
    // Cancel the stream subscription when the widget is disposed
    _streamSubscription.cancel();
    super.dispose();
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Liste des tickets",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 50,
              height: 50,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateTicketPage(),
                    ),
                  );
                },
                child: Icon(Icons.add),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                elevation: 4,
                shape: const CircleBorder(),
              ),
            ),
          ),
        ],
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: isAdmin
          ? MyTicketsListAdmin(
              status: _getSelectedStatus(),
              refreshTicketList: _refreshTicketList,
              filterTicketsByStatus: filterTicketsByStatus,
            )
          : MyTicketsListUser(
              filterTicketsByStatus: filterTicketsByStatus,
              refreshTicketList: _refreshTicketList,
            ),
      bottomNavigationBar: isAdmin
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              selectedItemColor: Colors.white,
              unselectedItemColor: Theme.of(context).colorScheme.inversePrimary,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.list,
                  ),
                  label: 'Not Started',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.refresh,
                  ),
                  label: 'In Progress',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.check,
                  ),
                  label: 'Completed',
                ),
              ],
            )
          : null,
    );
  }

  String _getSelectedStatus() {
    switch (_selectedIndex) {
      case 0:
        return 'Not Started';
      case 1:
        return 'In Progress';
      case 2:
        return 'Completed';
      default:
        return 'Not Started';
    }
  }

  Future<void> _refreshTicketList() async {
    // Fetch updated ticket data from Firestore
    final data = await filterTicketsByStatus(
        _getSelectedStatus()); // Assuming _getSelectedStatus() is available
    if (mounted) {
      setState(() {
        tickets = data['filteredTickets'];
      });
    }
  }
}

class MyTicketsListAdmin extends StatelessWidget {
  final String status;
  final VoidCallback refreshTicketList;
  final Function filterTicketsByStatus;

  const MyTicketsListAdmin({
    Key? key,
    required this.status,
    required this.refreshTicketList,
    required this.filterTicketsByStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: filterTicketsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final filteredTickets = snapshot.data!['filteredTickets'];
        final isAdmin = snapshot.data!['isAdmin'];

        return MyTicketsListWidget(
          filteredTickets: filteredTickets,
          isAdmin: isAdmin,
          refreshTicketList: refreshTicketList,
        );
      },
    );
  }
}

class MyTicketsListUser extends StatelessWidget {
  final Function filterTicketsByStatus; // Accept filterTicketsByStatus method
  final VoidCallback refreshTicketList; // Callback to refresh ticket list

  const MyTicketsListUser({
    Key? key,
    required this.filterTicketsByStatus,
    required this.refreshTicketList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: filterTicketsByStatus(''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final filteredTickets = snapshot.data!['filteredTickets'];
        final isAdmin = snapshot.data!['isAdmin'];

        return MyTicketsListWidget(
          filteredTickets: filteredTickets,
          isAdmin: isAdmin,
          refreshTicketList: refreshTicketList,
        );
      },
    );
  }
}

class MyTicketsListWidget extends StatefulWidget {
  final List<QueryDocumentSnapshot<Object?>> filteredTickets;
  final bool isAdmin;
  final VoidCallback refreshTicketList; // Callback to refresh ticket list

  const MyTicketsListWidget({
    Key? key,
    required this.filteredTickets,
    required this.isAdmin,
    required this.refreshTicketList,
  }) : super(key: key);

  @override
  State<MyTicketsListWidget> createState() => _MyTicketsListWidgetState();
}

class _MyTicketsListWidgetState extends State<MyTicketsListWidget> {
  late List<QueryDocumentSnapshot<Object?>> tickets;

  @override
  void initState() {
    super.initState();
    tickets = widget.filteredTickets; // Initialize tickets with filteredTickets
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: ListView.builder(
        itemCount: tickets.length,
        itemBuilder: (context, index) {
          final ticket = tickets[index].data() as Map<String, dynamic>;
          return MyListTile(
            title: "Title : " + ticket['Title'],
            subtitle: "Description : " +
                ticket['Description'] +
                "\nBy : " +
                ticket['UserEmail'],
            trailing: "Status\n" + ticket['Status'],
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                // Swipe to the right, delete ticket
                FirebaseFirestore.instance
                    .collection('Tickets')
                    .doc(tickets[index].id)
                    .delete();

                // After deleting, refresh the ticket list
                widget.refreshTicketList();
              } else if (direction == DismissDirection.startToEnd) {
                // Swipe to the left, navigate to update page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UpdateTicketPage(
                      ticketId: tickets[index].id,
                      currentTitle: ticket['Title'],
                      currentPriority: ticket['Priority'],
                      currentDescription: ticket['Description'],
                      currentStatus: ticket['Status'],
                      isAdmin: widget.isAdmin,
                    ),
                  ),
                ).then((result) {
                  if (result != null && result == 'cancel') {
                    // If update is canceled, refresh the ticket list
                    widget.refreshTicketList();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Update canceled")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ticket updated")),
                    );
                  }
                });
              }
            },
          );
        },
      ),
    );
  }
}
