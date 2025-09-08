import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/widgets/common/themed_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/database.dart';
import '../widgets/barcode_scanner_field.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  
  late String _name;
  late String _description;
  late double _price;
  String? _imageUrl; // Changed to nullable
  late String _category;
  late double _cost;
  late int _quantity;
  late TextEditingController _barcodeController;
  File? _imageFile;
  bool _isSaving = false;
  String? _oldImagePath;
  // initialize rankingScore to 0.0
  double _rankingScore = 0.0; // Not used in form, but can

  final List<String> _categories = ['boisson', 'jus', 'jus gaz', 'canet', 'mini'];

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _description = widget.product?.description ?? '';
    _price = widget.product?.price ?? 0;
    _imageUrl = widget.product?.imageUrl; // Can be null
    _category = widget.product?.category ?? _categories[0];
    _cost = widget.product?.cost ?? 0;
    _quantity = widget.product?.quantity ?? 0;
    _barcodeController = TextEditingController(text: widget.product?.barcode);
    _rankingScore = widget.product?.rankingScore ?? 0.0;
    
    if (widget.product?.imageUrl != null && widget.product!.imageUrl!.isNotEmpty) {
      _oldImagePath = widget.product!.imageUrl;
    }
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }

  Future<String> _getImagePath(String imageName) async {
    final appDir = await getApplicationDocumentsDirectory();
    return '${appDir.path}/app_images/$imageName';
  }
Future<void> _pickImage() async {
  try {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 70,
      maxWidth: 1024,
    );

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/app_images');

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // Generate unique filename
    final extension = p.extension(imageFile.path);
    final imageName = '${Uuid().v4()}$extension';
    final newPath = '${imagesDir.path}/$imageName';

    // Copy image to app dir
    final copiedImage = await imageFile.copy(newPath);

    setState(() {
      _imageFile = copiedImage;
      _imageUrl = copiedImage.path; // ✅ save full path
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to pick image: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
Future<void> _removeImage() async {
  if (_imageUrl != null && _imageUrl!.isNotEmpty) {
    try {
      final file = File(_imageUrl!);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image file: $e');
    }
  }

  setState(() {
    _imageFile = null;
    _imageUrl = null;
  });
}

Future<void> _cleanupOldImage() async {
  if (_oldImagePath != null && _oldImagePath != _imageUrl) {
    try {
      final file = File(_oldImagePath!);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error cleaning up old image: $e');
    }
  }
}

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() => _isSaving = true);
    
    final db = Provider.of<AppDatabase>(context, listen: false);
    final product = ProductsCompanion(
      id: widget.product != null 
          ? drift.Value(widget.product!.id) 
          : drift.Value(const Uuid().v4()),
      name: drift.Value(_name),
      description: drift.Value(_description),
      price: drift.Value(_price),
      imageUrl: drift.Value(_imageUrl ?? ''), // Handle null case
      category: drift.Value(_category),
      cost: drift.Value(_cost),
      quantity: drift.Value(_quantity),
      barcode: drift.Value(_barcodeController.text),
      rankingScore: drift.Value(_rankingScore),
    );

    try {
      if (widget.product == null) {
        await db.into(db.products).insert(product);
      } else {
        await db.update(db.products).replace(product);
        // Clean up old image if it was replaced
        await _cleanupOldImage();
      }
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving product: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
Widget _buildImagePreview() {
  final path = _imageFile?.path ?? _imageUrl;

  if (path != null && path.isNotEmpty) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image_outlined, size: 50),
      );
    } else {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
      return const Icon(Icons.broken_image_outlined, size: 50);
    }
  }

  return const Icon(Icons.camera_alt_outlined, size: 50);
}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ThemedScaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add New Product' : 'Edit Product'),
        actions: [
          if (widget.product != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isSaving ? null : () => _showDeleteDialog(context),
            ),
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImagePicker(context, colorScheme),
                    const SizedBox(height: 24),
                    _buildTextField(
                      initialValue: _name,
                      labelText: 'Product Name',
                      validator: (value) => 
                          value == null || value.isEmpty ? 'Please enter a name.' : null,
                      onSaved: (value) => _name = value!,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      initialValue: _description,
                      labelText: 'Description',
                      maxLines: 3,
                      onSaved: (value) => _description = value!,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            initialValue: _price.toString(),
                            labelText: 'Price',
                            keyboardType: TextInputType.number,
                            validator: (value) => 
                                (value == null || double.tryParse(value) == null) 
                                ? 'Enter a valid price.' 
                                : null,
                            onSaved: (value) => _price = double.parse(value!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            initialValue: _cost.toString(),
                            labelText: 'Cost',
                            keyboardType: TextInputType.number,
                            validator: (value) => 
                                (value == null || double.tryParse(value) == null) 
                                ? 'Enter a valid cost.' 
                                : null,
                            onSaved: (value) => _cost = double.parse(value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      initialValue: _quantity.toString(),
                      labelText: 'Quantity',
                      keyboardType: TextInputType.number,
                      validator: (value) => 
                          (value == null || int.tryParse(value) == null) 
                          ? 'Enter a valid quantity.' 
                          : null,
                      onSaved: (value) => _quantity = int.parse(value!),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(),
                    const SizedBox(height: 16),
                    BarcodeScannerField(controller: _barcodeController),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: _isSaving 
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_alt_outlined),
                      label: Text(_isSaving ? 'Saving...' : 'Save Product'),
                      onPressed: _isSaving ? null : _saveForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePicker(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: _buildImagePreview(),
              ),
            ),
          ),
          if (_imageUrl != null && _imageUrl!.isNotEmpty || _imageFile != null) 
            Positioned(
              top: 0,
              right: 0,
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.red,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: _removeImage,
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: FloatingActionButton(
              mini: true,
              onPressed: _pickImage,
              child: const Icon(Icons.edit, size: 20),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildTextField({
  required String initialValue,
  required String labelText,
  int maxLines = 1,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
  void Function(String?)? onSaved,
}) {
  final controller = TextEditingController(text: initialValue);

  return Focus(
    onFocusChange: (hasFocus) {
      // If field has focus and value is 0 or 0.0, clear it
      if (hasFocus && (controller.text.trim() == "0" || controller.text.trim() == "0.0")) {
        controller.clear();
      }
    },
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        alignLabelWithHint: true,
      ),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: (_) => onSaved?.call(controller.text), // ✅ Use controller.text
    ),
  );
}

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: InputDecoration(
        labelText: 'Category',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _category = newValue!;
        });
      },
    );
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Product'),
          content: const Text('Are you sure you want to delete this product?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteProduct();
              },
            ),
          ],
        );
      },
    );
  }

Future<void> _deleteProduct() async {
  setState(() => _isSaving = true);

  try {
    final db = Provider.of<AppDatabase>(context, listen: false);
    await db.deleteProduct(widget.product!.id);

    // Clean up associated image
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      final file = File(_imageUrl!);
      if (await file.exists()) {
        await file.delete();
      }
    }

    Navigator.of(context).pop();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error deleting product: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
    setState(() => _isSaving = false);
  }
}
}