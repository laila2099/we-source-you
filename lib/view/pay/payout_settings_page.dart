import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'payout_settings_controller.dart';

class PayoutSettingsPage extends GetView<PayoutSettingsController> {
  const PayoutSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: const Text('Payout settings'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: c.load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.error.value.isNotEmpty) {
          return Center(child: Text(c.error.value));
        }

        final selected = c.selectedProvider.value;

        final panel = _Panel(
          child: LayoutBuilder(
            builder: (context, cs) {
              final narrow = cs.maxWidth < 860;

              final left = _LeftMethods(
                selected: selected,
                stripeReady: c.selectedProvider.value == 'stripe',
                paypalReady: c.selectedProvider.value == 'paypal',
                onPick: c.pickProvider,
              );

              final right = _RightForm(
                provider: selected,
                stripeReady: c.stripeReady,
                stripeAccountId: c.stripeAccountId,
                paypalReady: c.paypalReady,
                paypalEmail: c.paypalEmail,
              );

              final confirm = _ConfirmBar(
                text: 'Confirm prefer payout method',
                enabled: c.isSelectedReady(selected),
                onPressed: () async {
                  if (!c.isSelectedReady(selected)) {
                    Get.snackbar('Not ready', 'Complete setup first.');
                    return;
                  }
                  await c.setDefault(selected);
                },
              );

              if (narrow) {
                return Column(
                  children: [
                    left,
                    const SizedBox(height: 18),
                    right,
                    const SizedBox(height: 16),
                    confirm,
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 250, child: left),
                      const SizedBox(width: 18),
                      Expanded(child: right),
                    ],
                  ),
                  const SizedBox(height: 16),
                  confirm,
                ],
              );
            },
          ),
        );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1020),
            child: panel,
          ),
        );
      }),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(18),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 28,
            spreadRadius: 2,
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _LeftMethods extends StatelessWidget {
  final String selected;
  final bool stripeReady;
  final bool paypalReady;
  final void Function(String provider) onPick;

  const _LeftMethods({
    required this.selected,
    required this.stripeReady,
    required this.paypalReady,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PAYOUT METHOD',
          style: TextStyle(
            letterSpacing: 0.6,
            fontWeight: FontWeight.w800,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 12),
        _MethodCard(
          title: 'Stripe',
          selected: selected == 'stripe',
          ready: stripeReady,
          leading: const _FakeLogo(text: 'STRIPE', color: Color(0xFF635BFF)),
          onTap: () => onPick('stripe'),
        ),
        const SizedBox(height: 12),
        _MethodCard(
          title: 'PayPal',
          selected: selected == 'paypal',
          ready: paypalReady,
          leading: const _FakeLogo(text: 'PayPal', color: Color(0xFF003087)),
          onTap: () => onPick('paypal'),
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final String title;
  final bool selected;
  final bool ready;
  final Widget leading;
  final VoidCallback onTap;

  const _MethodCard({
    required this.title,
    required this.selected,
    required this.ready,
    required this.leading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF6CC9F2) : Colors.black12;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 84,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: selected ? 2 : 1),
          color: Colors.white,
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            _MiniTick(ready: ready),
          ],
        ),
      ),
    );
  }
}

class _FakeLogo extends StatelessWidget {
  final String text;
  final Color color;
  const _FakeLogo({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
        color: Colors.white,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: color,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _MiniTick extends StatelessWidget {
  final bool ready;
  const _MiniTick({required this.ready});

  @override
  Widget build(BuildContext context) {
    return Icon(
      ready ? Icons.check_circle : Icons.radio_button_unchecked,
      color: ready ? Colors.green : Colors.black26,
      size: 22,
    );
  }
}

/// ========= RIGHT FORM =========
class _RightForm extends StatelessWidget {
  final String provider;
  final bool stripeReady;
  final String stripeAccountId;
  final bool paypalReady;
  final String paypalEmail;

  const _RightForm({
    required this.provider,
    required this.stripeReady,
    required this.stripeAccountId,
    required this.paypalReady,
    required this.paypalEmail,
  });

  @override
  Widget build(BuildContext context) {
    final isStripe = provider == 'stripe';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isStripe ? 'Stripe details' : 'PayPal details',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        const SizedBox(height: 14),
        if (isStripe) ...[
          _Field(
            label: 'Connect Account ID',
            value: stripeAccountId.isEmpty ? '—' : stripeAccountId,
            ok: stripeReady,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Status',
            value: stripeReady ? 'Connected' : 'Not connected',
            ok: stripeReady,
          ),
        ] else ...[
          _Field(
            label: 'PayPal Email',
            value: paypalEmail.isEmpty ? '—' : paypalEmail,
            ok: paypalReady,
          ),
          const SizedBox(height: 12),
          _Field(
            label: 'Status',
            value: paypalReady ? 'Email saved' : 'Missing email',
            ok: paypalReady,
          ),
        ],
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final c = Get.find<PayoutSettingsController>();
                  if (isStripe) {
                    await c.openStripe();
                  } else {
                    await _openPayPalDialog(
                      context,
                      c.paypalEmail,
                      c.savePayPalEmail,
                    );
                  }
                },
                icon: Icon(isStripe ? Icons.open_in_new : Icons.edit),
                label: Text(
                  isStripe
                      ? (stripeReady ? 'Open onboarding' : 'Setup Stripe')
                      : (paypalReady ? 'Edit email' : 'Add email'),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openPayPalDialog(
    BuildContext context,
    String initialEmail,
    Future<void> Function(String) onSave,
  ) async {
    final ctrl = TextEditingController(text: initialEmail);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('PayPal payout email'),
          content: SizedBox(
            width: 520,
            child: TextField(
              controller: ctrl,
              decoration: const InputDecoration(
                labelText: 'PayPal business email',
                hintText: 'name@domain.com',
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await onSave(ctrl.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    ctrl.dispose();
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final bool ok;

  const _Field({required this.label, required this.value, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Icon(
            ok ? Icons.check_circle : Icons.check_circle_outline,
            color: ok ? Colors.green : Colors.black26,
          ),
        ],
      ),
    );
  }
}

/// ========= CONFIRM BAR =========
class _ConfirmBar extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback onPressed;

  const _ConfirmBar({
    required this.text,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5DAFF1),
          disabledBackgroundColor: Colors.black12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
