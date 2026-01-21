import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  ChatService({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final u = _auth.currentUser;
    if (u == null) throw Exception('Not signed in');
    return u.uid;
  }

  DocumentReference<Map<String, dynamic>> conversationRef(
    String conversationId,
  ) {
    return _db.collection('conversations').doc(conversationId);
  }

  CollectionReference<Map<String, dynamic>> messagesRef(String conversationId) {
    return conversationRef(conversationId).collection('messages');
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchConversation(
    String conversationId,
  ) {
    return conversationRef(conversationId).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMessages(
    String conversationId, {
    int limit = 200,
  }) {
    return messagesRef(
      conversationId,
    ).orderBy('createdAt', descending: true).limit(limit).snapshots();
  }

  /// Send text message + update conversation lastMessage fields
  Future<void> sendText({
    required String conversationId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final uid = _uid;
    final convRef = conversationRef(conversationId);
    final msgRef = messagesRef(conversationId).doc();

    final convSnap = await convRef.get();
    final conv = convSnap.data();
    if (conv == null) throw Exception('Conversation not found');

    final status = (conv['status'] ?? 'open').toString();
    if (status != 'open') throw Exception('Conversation is read-only');

    final participants = List<String>.from(
      (conv['participants'] ?? []) as List,
    );
    final otherId = participants.firstWhere((p) => p != uid, orElse: () => '');
    if (otherId.isEmpty) throw Exception('Other participant not found');

    final batch = _db.batch();

    batch.set(msgRef, {
      'senderId': uid,
      'type': 'text',
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(convRef, {
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageText': trimmed,
      'lastMessageSenderId': uid,

      // ✅ increment unread for the other user
      'unread.$otherId': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// System message (client-side). Useful for local banners/history.
  /// NOTE: Only works while conversation is open (rules).
  Future<void> sendSystem({
    required String conversationId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final convRef = conversationRef(conversationId);
    final msgRef = messagesRef(conversationId).doc();

    final batch = _db.batch();
    batch.set(msgRef, {
      'senderId':
          _uid, // or 'system' if you allow; rules currently require senderId==uid
      'type': 'system',
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.update(convRef, {
      'lastMessageAt': FieldValue.serverTimestamp(),
      'lastMessageText': trimmed,
      'lastMessageSenderId': _uid,
    });

    await batch.commit();
  }
}
