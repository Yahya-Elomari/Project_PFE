import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TechnicienPage extends StatelessWidget {
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
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: TicketsInProgressList(),
    );
  }
}

class TicketsInProgressList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Tickets')
          .where('Status', isEqualTo: 'In Progress')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final List<DocumentSnapshot> tickets = snapshot.data!.docs;

        if (tickets.isEmpty) {
          return Center(child: Text('No tickets in progress'));
        }

        return ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            final ticket = tickets[index].data() as Map<String, dynamic>;
            return TicketTile(
              title: ticket['Title'],
              userEmail: ticket['UserEmail'],
              description: ticket['Description'],
              onComplete: () {
                completeTicket(tickets[index].id);
              },
            );
          },
        );
      },
    );
  }

  Future<void> completeTicket(String ticketId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Tickets')
          .doc(ticketId)
          .update({'Status': 'Completed'});
      print('Ticket marked as completed successfully.');
    } catch (error) {
      print('Failed to complete ticket: $error');
      throw error; // Rethrow the error to handle it in the UI or caller
    }
  }
}

class TicketTile extends StatelessWidget {
  final String title;
  final String userEmail;
  final String description;
  final VoidCallback onComplete;

  const TicketTile({
    Key? key,
    required this.title,
    required this.userEmail,
    required this.description,
    required this.onComplete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      subtitle: Text(userEmail),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(description),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onComplete,
              child: Text(
                'Completed',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
