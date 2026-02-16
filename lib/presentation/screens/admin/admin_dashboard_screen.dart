import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/property_model.dart';
import '../../../domain/models/user_model.dart';
import '../../providers/auth_flows_provider.dart';
import '../../providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserModelProvider).valueOrNull;
    final isAdmin = user?.isAdmin ?? false;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة الأدمن'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home_work), text: 'العقارات'),
              Tab(icon: Icon(Icons.people), text: 'المستخدمين'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                ref.read(authFlowsProvider.notifier).signOut();
                context.go('/');
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (!isAdmin)
              Material(
                color: Colors.orange.shade100,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'عرض فقط - سجّل دخول كـ Admin للتعديل',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  const _ListingsTab(),
                  const _UsersTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingsTab extends StatelessWidget {
  const _ListingsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('properties')
          .snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('خطأ: ${snap.error}'),
              ],
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_work_outlined, size: 64, color: AppTheme.slateGray),
                const SizedBox(height: 16),
                const Text('لا توجد عقارات في Firestore'),
                const SizedBox(height: 8),
                Text(
                  'العقارات في الصفحة الرئيسية من البيانات التجريبية',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            try {
              final d = docs[i].data() as Map<String, dynamic>;
              final id = docs[i].id;
              final p = PropertyModel.fromJson({'id': id, ...d});
            return Card(
              child: ListTile(
                title: Text(p.title),
                subtitle: Text('${p.formattedPrice} • ${p.categoryLabel}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Chip(
                      label: Text(p.isVerified ? 'Verified' : 'Pending'),
                      backgroundColor: p.isVerified
                          ? AppTheme.verifiedGreen.withValues(alpha: 0.2)
                          : Colors.orange.withValues(alpha: 0.2),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        p.isVerified ? Icons.block : Icons.verified,
                        color: AppTheme.navyBlue,
                      ),
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('properties')
                            .doc(id)
                            .update({
                          'isVerified': !p.isVerified,
                          'updatedAt': DateTime.now().toIso8601String(),
                        });
                      },
                    ),
                  ],
                ),
              );
            } catch (e) {
              return Card(
                child: ListTile(
                  title: const Text('خطأ في تحميل العقار'),
                  subtitle: Text('$e'),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text('خطأ: ${snap.error}'),
              ],
            ),
          );
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_outline, size: 64, color: AppTheme.slateGray),
                const SizedBox(height: 16),
                const Text('لا يوجد مستخدمون'),
                const SizedBox(height: 8),
                Text(
                  'سجّل الدخول أولاً (OTP أو Google) لإنشاء مستخدمين',
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final u = UserModel.fromJson({'id': docs[i].id, ...d});
            return Card(
              child: ListTile(
                leading: u.photoUrl != null
                    ? CircleAvatar(backgroundImage: NetworkImage(u.photoUrl!))
                    : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(u.displayName ?? u.phoneNumber),
                subtitle: Text('${u.role} • ${u.phoneNumber}'),
                trailing: Chip(
                  label: Text(u.role),
                  backgroundColor: u.role == AppConstants.roleAdmin
                      ? AppTheme.navyBlue.withValues(alpha: 0.2)
                      : AppTheme.slateGray.withValues(alpha: 0.2),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
