import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _purchaseController = TextEditingController();
  final TextEditingController _sellingController = TextEditingController();
  final TextEditingController _variantNameController = TextEditingController();
  final TextEditingController _variantStockController = TextEditingController();
  final List<ProductVariant> _variants = [];
  String? _imagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 900,
    );
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _addVariant() {
    final name = _variantNameController.text.trim();
    final stock = int.tryParse(_variantStockController.text.trim());
    if (name.isEmpty || stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi nama varian dan stok dengan benar'),
        ),
      );
      return;
    }

    setState(() {
      _variants.add(ProductVariant(name: name, stock: stock));
      _variantNameController.clear();
      _variantStockController.clear();
    });
  }

  void _saveProduct() {
    if (!_formKey.currentState!.validate()) return;
    if (_variants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tambahkan minimal satu varian stok')),
      );
      return;
    }

    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      brand: _brandController.text.trim(),
      purchasePrice: double.parse(_purchaseController.text.trim()),
      sellingPrice: double.parse(_sellingController.text.trim()),
      variants: List<ProductVariant>.from(_variants),
      imagePath: _imagePath,
    );

    context.read<ProductController>().addProduct(product);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _purchaseController.dispose();
    _sellingController.dispose();
    _variantNameController.dispose();
    _variantStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: const Color(0xFF91C2F4),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade200,
                    image: _imagePath != null
                        ? DecorationImage(
                            image: FileImage(File(_imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imagePath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.camera_alt_outlined,
                              size: 48,
                              color: Colors.black45,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Ambil foto produk',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField(_nameController, 'Name'),
              const SizedBox(height: 16),
              _buildTextField(_categoryController, 'Category'),
              const SizedBox(height: 16),
              _buildTextField(_brandController, 'Brand'),
              const SizedBox(height: 24),
              const Text(
                'Price',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      _purchaseController,
                      'Purchase',
                      number: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      _sellingController,
                      'Selling',
                      number: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Variant Stock',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_variantNameController, 'Name'),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 100,
                    child: _buildTextField(
                      _variantStockController,
                      'Stock',
                      number: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF91C2F4),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _addVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_variants.isNotEmpty)
                Column(
                  children: _variants
                      .map(
                        (variant) => Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(variant.name),
                            subtitle: Text('Stock ${variant.stock}'),
                            leading: const Icon(
                              Icons.inventory_2_outlined,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF91C2F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black54),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 2.0),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Field ini tidak boleh kosong';
        }
        if (number && double.tryParse(value.trim()) == null) {
          return 'Masukkan angka yang valid';
        }
        return null;
      },
    );
  }
}
