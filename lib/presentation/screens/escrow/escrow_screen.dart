import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

/// Escrow simulation: Seriousness Fee held until deal confirmation.
class EscrowScreen extends ConsumerStatefulWidget {
  const EscrowScreen({
    super.key,
    required this.propertyId,
    required this.amount,
  });

  final String propertyId;
  final double amount;

  @override
  ConsumerState<EscrowScreen> createState() => _EscrowScreenState();
}

class _EscrowScreenState extends ConsumerState<EscrowScreen> {
  bool _isLoading = false;
  bool _confirmed = false;

  Future<void> _paySeriousnessFee() async {
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(seconds: 2)); // Simulate payment
    if (mounted) {
      setState(() {
        _isLoading = false;
        _confirmed = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Seriousness fee held in escrow. It will be released when the deal is confirmed.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seriousness Fee (Escrow)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.account_balance_wallet, size: 64, color: AppTheme.navyBlue),
                    const SizedBox(height: 16),
                    Text(
                      'EGP ${widget.amount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppTheme.navyBlue,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Seriousness Fee',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.slateGray,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This amount is held securely until the deal is confirmed by both parties.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (!_confirmed)
              ElevatedButton(
                onPressed: _isLoading ? null : _paySeriousnessFee,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Pay Seriousness Fee'),
              )
            else
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Back to Property'),
              ),
          ],
        ),
      ),
    );
  }
}
