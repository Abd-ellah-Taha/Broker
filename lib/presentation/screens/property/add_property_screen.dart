import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/property_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/property_provider.dart';
import '../../providers/services_provider.dart';

class AddPropertyScreen extends ConsumerStatefulWidget {
  const AddPropertyScreen({super.key, this.property, this.propertyId});

  final PropertyModel? property;
  final String? propertyId;

  @override
  ConsumerState<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends ConsumerState<AddPropertyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _governorateController = TextEditingController();
  String _category = AppConstants.categoryResidential;
  bool _isLoading = false;
  PropertyModel? _editingProperty;
  List<XFile> _selectedImages = [];
  bool _isGeneratingAi = false;

  @override
  void initState() {
    super.initState();
    _initFromProperty(widget.property);
  }

  Future<void> _pickImages() async {
    final storage = ref.read(storageServiceProvider);
    final picked = await storage.pickImages(max: 5);
    if (picked.isNotEmpty) setState(() => _selectedImages = picked);
  }

  Future<void> _generateAiDescription() async {
    if (_selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one image first')),
      );
      return;
    }
    setState(() => _isGeneratingAi = true);
    try {
      final gemini = ref.read(geminiServiceProvider);
      final desc = await gemini.generateDescriptionFromImages(_selectedImages);
      if (desc.isNotEmpty && mounted) {
        _descController.text = desc;
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('AI error: $e')),
        );
      }
    }
    if (mounted) setState(() => _isGeneratingAi = false);
  }

  void _initFromProperty(PropertyModel? p) {
    if (p != null) {
      _titleController.text = p.title;
      _descController.text = p.description;
      _priceController.text = p.price.toStringAsFixed(0);
      _areaController.text = p.area?.toString() ?? '';
      _addressController.text = p.location.address ?? '';
      _cityController.text = p.location.city ?? '';
      _governorateController.text = p.location.governorate ?? '';
      _category = p.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _governorateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserModelProvider).valueOrNull;
    if (user == null) return;
    setState(() => _isLoading = true);

    final location = PropertyLocation(
      latitude: 30.0444,
      longitude: 31.2357,
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      governorate: _governorateController.text.trim().isEmpty ? null : _governorateController.text.trim(),
    );
    final editing = _editingProperty;
    final property = PropertyModel(
      id: editing?.id ?? 'temp',
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text) ?? 0,
      category: _category,
      location: location,
      ownerId: user.id,
      area: double.tryParse(_areaController.text),
      imageUrls: editing?.imageUrls ?? [],
      isVerified: editing?.isVerified ?? false,
      createdAt: editing?.createdAt,
      updatedAt: DateTime.now(),
    );

    try {
      final repo = ref.read(propertyRepositoryProvider);
      var imageUrls = editing?.imageUrls ?? [];

      if (editing != null) {
        if (useFirestore && _selectedImages.isNotEmpty) {
          final storage = ref.read(storageServiceProvider);
          imageUrls = await storage.uploadPropertyImages(
            propertyId: editing.id,
            files: _selectedImages,
            userId: user.id,
          );
        }
        await repo.updateProperty(property.copyWith(id: editing.id, imageUrls: imageUrls));
      } else {
        final id = await repo.createProperty(property);
        if (useFirestore && _selectedImages.isNotEmpty) {
          final storage = ref.read(storageServiceProvider);
          imageUrls = await storage.uploadPropertyImages(
            propertyId: id,
            files: _selectedImages,
            userId: user.id,
          );
          await repo.updateProperty(property.copyWith(id: id, imageUrls: imageUrls));
        }
      }
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(editing != null ? 'Updated' : 'Added')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final propertyAsync = widget.propertyId != null
        ? ref.watch(propertyByIdProvider(widget.propertyId!))
        : null;
    final existingProperty = widget.property ?? propertyAsync?.valueOrNull;

    _editingProperty = existingProperty;
    if (propertyAsync != null && existingProperty != null && _titleController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initFromProperty(existingProperty);
        setState(() {});
      });
    }

    if (widget.propertyId != null && propertyAsync?.isLoading == true) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(existingProperty != null ? 'Edit Property' : 'Add Property'),
        actions: [
          if (_editingProperty != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete property?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                    ],
                  ),
                );
                if (ok == true) {
                  await ref.read(propertyRepositoryProvider).deleteProperty(_editingProperty!.id);
                  if (mounted) context.pop();
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.add_photo_alternate),
                    label: Text('Add Photos (${_selectedImages.length})'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _isGeneratingAi ? null : _generateAiDescription,
                  icon: _isGeneratingAi
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: const Text('AI Desc'),
                ),
              ],
            ),
            if (_selectedImages.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _XFileThumb(file: _selectedImages[i]),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 4,
              validator: (v) => v?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price (EGP)'),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.trim().isEmpty ?? true) return 'Required';
                if (double.tryParse(v!) == null) return 'Invalid number';
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(labelText: 'Area (sqm) - optional'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: AppConstants.propertyCategories
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Text(c == AppConstants.categoryResidential ? 'Residential' : 'Commercial'),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _governorateController,
              decoration: const InputDecoration(labelText: 'Governorate'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_editingProperty != null ? 'Update' : 'Add Property'),
            ),
          ],
        ),
      ),
    );
  }
}

class _XFileThumb extends StatelessWidget {
  const _XFileThumb({required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: file.readAsBytes(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.image),
          );
        }
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            snap.data!,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }
}
