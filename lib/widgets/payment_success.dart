import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../view/inbox/chat.dart';

class PaymentSuccessPage extends StatefulWidget {
  const PaymentSuccessPage({super.key});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  bool _navigated = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _start();
      print("PaymentSuccessPage opened");
      print("contractId param = ${Get.parameters['contractId']}");
      print("currentUser = ${FirebaseAuth.instance.currentUser?.uid}");
    });
  }

  Future<String> _getOrWaitConversationId(
    String contractId, {
    Duration timeout = const Duration(seconds: 25),
  }) async {
    final ref = FirebaseFirestore.instance
        .collection('contracts')
        .doc(contractId);

    // 1) Read immediately once (in case the value already exists)
    final first = await ref.get();
    final cid1 = first.data()?['conversationId'];
    if (cid1 is String && cid1.isNotEmpty) return cid1;

    // 2) If not present, listen until it appears (with timeout)
    return await ref
        .snapshots()
        .map((s) => s.data()?['conversationId'])
        .where((cid) => cid is String && (cid as String).isNotEmpty)
        .cast<String>()
        .first
        .timeout(timeout);
  }

  Future<void> _start() async {
    final contractId = Get.parameters['contractId'];

    if (contractId == null || contractId.isEmpty) {
      if (!mounted) return;
      setState(() => _error = 'Missing contractId');
      return;
    }

    // One-time auth check
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (!mounted) return;
      setState(() => _error = 'Session expired. Please login.');
      return;
    }

    try {
      final conversationId = await _getOrWaitConversationId(contractId);

      if (!mounted) return;
      if (_navigated) return;
      _navigated = true;

      // Safe navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Get.off(() => ChatPage(conversationId: conversationId));
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _error = 'Timed out while confirming payment. Try again.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return const Scaffold(body: Center(child: Text('Confirming payment...')));
  }
}
