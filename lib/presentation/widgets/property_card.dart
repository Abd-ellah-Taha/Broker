import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/property_model.dart';

/// Property card with Verified badge for Home Screen list.
class PropertyCard extends StatelessWidget {
  const PropertyCard({
    super.key,
    required this.property,
  });

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/property/${property.id}'),
        child: isWide ? _buildWideLayout(context) : _buildCompactLayout(context),
      ),
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThumbnail(context, height: 100),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: _buildContent(context),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThumbnail(context, height: 160),
        Padding(
          padding: const EdgeInsets.all(16),
          child: _buildContent(context),
        ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context, {required double height}) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final width = isWide ? null : 120.0;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: AppTheme.slateGray.withValues(alpha: 0.15),
            child: Center(
              child: Icon(
                property.isResidential ? Icons.home_rounded : Icons.business_rounded,
                size: 48,
                color: AppTheme.slateGray.withValues(alpha: 0.4),
              ),
            ),
          ),
          if (property.imageUrls.isNotEmpty)
            Image.network(
              property.imageUrls.first,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          if (property.isVerified)
            Positioned(
              top: 8,
              right: 8,
              child: _VerifiedBadge(),
            ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.navyBlue,
                fontWeight: FontWeight.w600,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: AppTheme.slateGray,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                property.location.address ??
                    '${property.location.city ?? ''}, ${property.location.governorate ?? ''}',
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              property.formattedPrice,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.navyBlue,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Chip(
              label: Text(
                property.categoryLabel,
                style: const TextStyle(fontSize: 12),
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.verifiedGreen,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
