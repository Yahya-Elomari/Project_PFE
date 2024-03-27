import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/*
this databse stores tickets that users have published in the app.
it is stored in a collection called Tickets in Firebase

Each post contains :
'UserEmail'
'UserId'
'Title'
'Priority'
'AssignedTo'
'TimeStamp'
 */

class FirestoreDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //send a Ticket
  Future<void> addTicket(String id, String title, String priority,
      String description, String status) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('Tickets').add({
          'UserEmail': user.email,
          'Tid': id,
          'Title': title,
          'Priority': priority,
          'Description': description,
          'Status': status,
          'TimeStamp': Timestamp.now(),
        });
      } catch (error) {
        print('Error adding ticket: $error');
        throw error;
      }
    } else {
      print('User is not authenticated.');
    }
  }

  //read tickets from database
  Stream<QuerySnapshot> getTicketsStream() {
    final ticketsStream = FirebaseFirestore.instance
        .collection('Tickets')
        .orderBy('TimeStamp', descending: false)
        .snapshots();
    return ticketsStream;
  }

  Future<bool> isAdmin() async {
    try {
      // get the current user data from firebase
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.email)
            .get();
        if (userSnapshot.exists && userSnapshot.data() != null) {
          // get data from the user document
          String? userRole = userSnapshot.get('role');
          // check if the user has the admin role
          if (userRole == 'admin') {
            return true;
          }
        }
      }
      // error if not logged in or there is the user doesn't have an admin role
      return false;
    } catch (e) {
      print('Error checking admin role: $e');
      return false;
    }
  }

  Future<bool> isTech() async {
    try {
      // get the current user data from firebase
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser.email)
            .get();
        if (userSnapshot.exists && userSnapshot.data() != null) {
          // get data from the user document
          String? userRole = userSnapshot.get('role');
          // check if the user has the admin role
          if (userRole == 'tech') {
            return true;
          }
        }
      }
      // error if not logged in or there is the user doesn't have an admin role
      return false;
    } catch (e) {
      print('Error checking tech role: $e');
      return false;
    }
  }

  Future<void> updateTicket(
    String ticketId,
    String title,
    String priority,
    String description, {
    String? status,
  }) async {
    try {
      // Construct the data to be updated
      Map<String, dynamic> data = {
        'Title': title,
        'Priority': priority,
        'Description': description,
      };

      if (status != null) {
        data['Status'] = status;
      }

      // Update the ticket in Firestore
      await _db.collection('Tickets').doc(ticketId).update(data);
    } catch (e) {
      // Handle any errors that occur during the update process
      print('Error updating ticket: $e');
      rethrow; // Rethrow the exception to propagate it further if needed
    }
  }
}
