import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class EditProductPage extends StatefulWidget {
  final Product product;

  const EditProductPage({super.key, required this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _categoryController;
  late final TextEditingController _brandController;
  late final TextEditingController _purchaseController;
  late final TextEditingController _sellingController;
  final TextEditingController _variantNameController = TextEditingController();
  final TextEditingController _variantStockController = TextEditingController();
  late List<ProductVariant> _variants;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _categoryController = TextEditingController(text: widget.product.category);
    _brandController = TextEditingController(text: widget.product.brand);
    _purchaseController = TextEditingController(
      text: widget.product.purchasePrice.toString(),
    );
    _sellingController = TextEditingController(
      text: widget.product.sellingPrice.toString(),
    );
    _variants = List<ProductVariant>.from(widget.product.variants);
    _imagePath = widget.product.imagePath;
  }

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

    final updatedProduct = widget.product.copyWith(
      name: _nameController.text.trim(),
      category: _categoryController.text.trim(),
      brand: _brandController.text.trim(),
      purchasePrice: double.parse(_purchaseController.text.trim()),
      sellingPrice: double.parse(_sellingController.text.trim()),
      variants: List<ProductVariant>.from(_variants),
      imagePath: _imagePath,
    );

    context.read<ProductController>().updateProduct(updatedProduct);
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
        title: const Text('Edit Product'),
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
                  children: _variants.asMap().entries.map((entry) {
                    final index = entry.key;
                    final variant = entry.value;
                    return Card(
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
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _variants.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
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
                    'Update',
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
