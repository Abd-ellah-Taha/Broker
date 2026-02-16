import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/property_provider.dart';

class PropertyDetailsScreen extends ConsumerWidget {
  const PropertyDetailsScreen({
    super.key,
    required this.propertyId,
  });

  final String propertyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyAsync = ref.watch(propertyByIdProvider(propertyId));

    return Scaffold(
      body: propertyAsync.when(
        data: (property) {
          if (property == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_work_outlined, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Property not found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go back'),
                  ),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: AppTheme.slateGray.withValues(alpha: 0.2),
                        child: Center(
                          child: Icon(
                            property.isResidential
                                ? Icons.home_rounded
                                : Icons.business_rounded,
                            size: 80,
                            color: AppTheme.slateGray.withValues(alpha: 0.4),
                          ),
                        ),
                      ),
                      if (property.isVerified)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          right: 16,
                          child: _VerifiedBadge(),
                        ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.navyBlue,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: AppTheme.slateGray,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              property.location.address ??
                                  '${property.location.city ?? ''}, ${property.location.governorate ?? ''}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.navyBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              property.formattedPrice,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: AppTheme.navyBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Chip(
                              label: Text(property.categoryLabel),
                              backgroundColor: AppTheme.slateGray.withValues(alpha: 0.15),
                            ),
                          ],
                        ),
                      ),
                      if (property.area != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.square_foot, color: AppTheme.slateGray),
                            const SizedBox(width: 8),
                            Text(
                              '${property.area} sqm',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 20),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.navyBlue,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        property.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      _ActionButtons(property: property),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Failed to load property'),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.verifiedGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            'Verified',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.property});

  final dynamic property;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return isWide
        ? Row(
            children: [
              Expanded(child: _BookVisitButton(propertyId: property.id)),
              const SizedBox(width: 12),
              Expanded(
                child: _ChatButton(propertyId: property.id, ownerId: property.ownerId),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _EscrowButton(propertyId: property.id, amount: property.price * 0.01),
              ),
            ],
          )
        : Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: _BookVisitButton(propertyId: property.id),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _ChatButton(propertyId: property.id, ownerId: property.ownerId),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _EscrowButton(propertyId: property.id, amount: property.price * 0.01),
              ),
            ],
          );
  }
}

class _BookVisitButton extends StatelessWidget {
  const _BookVisitButton({required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => context.push('/property/$propertyId/booking'),
      icon: const Icon(Icons.calendar_month_rounded),
      label: const Text('Book a Visit'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class _EscrowButton extends StatelessWidget {
  const _EscrowButton({required this.propertyId, required this.amount});

  final String propertyId;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.push(
        '/property/$propertyId/escrow',
        extra: {'amount': amount},
      ),
      icon: const Icon(Icons.account_balance_wallet_outlined),
      label: const Text('Seriousness Fee'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton({
    required this.propertyId,
    required this.ownerId,
  });

  final String propertyId;
  final String ownerId;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.push(
        '/property/$propertyId/chat',
        extra: {'ownerId': ownerId},
      ),
      icon: const Icon(Icons.chat_bubble_outline_rounded),
      label: const Text('Chat with Owner'),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}
