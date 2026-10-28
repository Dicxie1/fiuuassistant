import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SyncService{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Sinchronize user data with Firestore
  Future<void> syncAllUserData() async{
    final user = _auth.currentUser;
    if(user == null) return;
    try{
      // Fetch user data from Firestore
      await _firestore.collection('emergency_contacts')
      .doc(user.uid)
      .get(const GetOptions(source: Source.serverAndCache));
      // Fetch User data from Firestore
      await _firestore.collection('users')
      .doc(user.uid)
      .get(const GetOptions(source: Source.serverAndCache));
      // get user progress data from Firestore
      await _firestore.collection('user_progress')
      .doc(user.uid)
      .get(const GetOptions(source: Source.serverAndCache));
      print('User data synced successfully');
    }catch(e){
      print('Error syncing user data: $e');
    }
  }
  void setupRealTimeListener(){
    final user= _auth.currentUser;
    if(user == null) return;
    _firestore.collection('emergency_contacts').doc(user.uid).snapshots().listen((snapshot) {
      if(snapshot.exists){
        print('Emergency contact data updated: ${snapshot.data()}');
      }
    });
    _firestore.collection('user_progress').doc(user.uid).snapshots().listen((snapshot) {
      if(snapshot.exists){
        print('User progress data updated: ${snapshot.data()}');
      }
    });
  }
}