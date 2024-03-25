import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:help_desk/components/my_list_tile.dart'; // Assuming MyListTile is used for displaying individual tickets
import 'package:help_desk/database/firestore.dart';
import 'package:help_desk/pages/create_ticket.dart';
import 'package:help_desk/pages/update_ticket_page.dart'; // Assuming this page is used for updating tickets

class TicketsListPage extends StatefulWidget {
  TicketsListPage({Key? key, required this.currentUser}) : super(key: key);
  final User? currentUser;

  @override
  State<TicketsListPage> createState() => _TicketsListPageState();
}

class _TicketsListPageState extends State<TicketsListPage> {
  int _selectedIndex = 0;
  bool isAdmin = false;

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
          ? MyTicketsList(status: _getSelectedStatus())
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: isAdmin
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.grey,
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
              selectedLabelStyle:
                  TextStyle(color: Theme.of(context).colorScheme.primary),
              unselectedLabelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary),
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
}

class MyTicketsList extends StatelessWidget {
  final String status;

  const MyTicketsList({Key? key, required this.status}) : super(key: key);

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
        final isAdmin = snapshot.data!['isAdmin'];
        final filteredTickets = snapshot.data!['filteredTickets'];

        return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: ListView.builder(
            itemCount: filteredTickets.length,
            itemBuilder: (context, index) {
              final ticket =
                  filteredTickets[index].data() as Map<String, dynamic>;
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
                        .doc(filteredTickets[index].id)
                        .delete();
                  } else if (direction == DismissDirection.startToEnd) {
                    // Swipe to the left, navigate to update page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdateTicketPage(
                          ticketId: filteredTickets[index].id,
                          currentTitle: ticket['Title'],
                          currentPriority: ticket['Priority'],
                          currentDescription: ticket['Description'],
                          currentStatus: ticket['Status'],
                          isAdmin: isAdmin,
                        ),
                      ),
                    ).then((_) {
                      // Refresh the ticket list when returning from the update page
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ticket updated")));
                    });
                  }
                },
              );
            },
          ),
        );
      },
    );
  }
}

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
          .where(
              (doc) => (doc.data() as Map<String, dynamic>)['Status'] == status)
          .toList();
    } else {
      filteredTickets = snapshot.docs
          .where((doc) =>
              (doc.data() as Map<String, dynamic>)['UserEmail'] ==
                  currentUserEmail &&
              (doc.data() as Map<String, dynamic>)['Status'] == status)
          .toList();
    }
  }

  return {'isAdmin': isAdmin, 'filteredTickets': filteredTickets};
}
