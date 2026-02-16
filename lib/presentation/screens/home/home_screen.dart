import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/property_model.dart';
import '../../providers/auth_flows_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/property_card.dart';
import '../../widgets/property_map_view.dart';

/// Home Screen: searchable map view + property cards with Verified badge.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _mapExpanded = true;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    ref.read(searchQueryProvider.notifier).state = _searchController.text;
    setState(() {}); // Rebuild for suffix clear button
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesProvider);
    final isWide = MediaQuery.of(context).size.width >= 800;

    final user = ref.watch(currentUserModelProvider).valueOrNull;
    final isOwner = user?.isOwner ?? false;

    return Scaffold(
      drawer: _AppDrawer(user: user, isOwner: isOwner),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_work_rounded, color: AppTheme.navyBlue),
            const SizedBox(width: 8),
            Text(AppConstants.appName),
          ],
        ),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.add_home_rounded),
              onPressed: () => context.push('/property/add'),
              tooltip: 'Add Property',
            ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (v) {
              if (v == 'login') {
                context.push('/auth/login');
              } else if (v == 'logout') {
                ref.read(authFlowsProvider.notifier).signOut();
              } else if (v == 'admin') {
                context.push('/admin');
              }
            },
            itemBuilder: (_) => [
              if (user == null)
                const PopupMenuItem(value: 'login', child: Text('تسجيل الدخول')),
              if (user != null) ...[
                if (user!.isAdmin)
                  const PopupMenuItem(value: 'admin', child: Text('Admin')),
                const PopupMenuItem(value: 'logout', child: Text('Sign out')),
              ],
            ],
          ),
        ],
      ),
      floatingActionButton: isOwner
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/property/add'),
              icon: const Icon(Icons.add),
              label: const Text('Add Property'),
            )
          : null,
      body: propertiesAsync.when(
        data: (properties) {
          if (properties.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.home_work_outlined, size: 80, color: AppTheme.slateGray),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد عقارات',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سجّل الدخول كـ Owner وأضف عقاراً من القائمة',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.slateGray,
                          ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => context.push('/auth/login'),
                      icon: const Icon(Icons.login),
                      label: const Text('تسجيل الدخول'),
                    ),
                  ],
                ),
              ),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              if (isWide) {
                return _buildDesktopLayout(context, properties);
              }
              return _buildMobileLayout(context, properties);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text('فشل تحميل العقارات'),
                const SizedBox(height: 8),
                Text('$e', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, List<PropertyModel> properties) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _buildSearchBar(context),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: properties.length,
                  itemBuilder: (_, i) => PropertyCard(property: properties[i]),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PropertyMapView(
              properties: properties,
              onPropertySelected: (_) {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, List<PropertyModel> properties) {
    return Column(
      children: [
        _buildSearchBar(context),
        GestureDetector(
          onTap: () => setState(() => _mapExpanded = !_mapExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _mapExpanded ? 220 : 56,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  PropertyMapView(
                    properties: properties,
                    onPropertySelected: (_) {},
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                      child: IconButton(
                        icon: Icon(
                          _mapExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: AppTheme.navyBlue,
                        ),
                        onPressed: () =>
                            setState(() => _mapExpanded = !_mapExpanded),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: properties.length,
            itemBuilder: (_, i) => PropertyCard(property: properties[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Search by location, city, or title...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
        ),
      ),
    );
  }
}

class _AppDrawer extends ConsumerWidget {
  const _AppDrawer({this.user, this.isOwner = false});

  final dynamic user;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppTheme.navyBlue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.home_work_rounded, size: 48, color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  user?.displayName ?? user?.phoneNumber ?? 'زائر',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('الرئيسية'),
            onTap: () {
              Navigator.pop(context);
              if (ModalRoute.of(context)?.settings.name != '/') {
                context.go('/');
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('تسجيل الدخول'),
            onTap: () {
              Navigator.pop(context);
              context.push('/auth/login');
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings),
            title: const Text('لوحة الأدمن / المستخدمين'),
            subtitle: const Text('عرض المستخدمين والعقارات'),
            onTap: () {
              Navigator.pop(context);
              context.push('/admin');
            },
          ),
          if (isOwner)
            ListTile(
              leading: const Icon(Icons.add_home),
              title: const Text('إضافة عقار'),
              onTap: () {
                Navigator.pop(context);
                context.push('/property/add');
              },
            ),
          if (user != null)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('تسجيل الخروج'),
              onTap: () {
                Navigator.pop(context);
                ref.read(authFlowsProvider.notifier).signOut();
              },
            ),
        ],
      ),
    );
  }
}
