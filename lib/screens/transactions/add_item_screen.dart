// lib/screens/transactions/add_item_screen.dart
import 'package:flutter/material.dart';
import 'package:zooogle/widgets/transactions/unit_selection_dialog.dart';

// InvoiceLineItem class remains the same...
class InvoiceLineItem {
  final String name;
  final double quantity;
  final double rate;
  final String unit;
  final String taxType;

  InvoiceLineItem({
    required this.name,
    required this.quantity,
    required this.rate,
    required this.unit,
    required this.taxType,
  });

  // Calculated property for the total
  double get total => quantity * rate;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'rate': rate,
        'unit': unit,
        'taxType': taxType,
        'total': total,
      };
}


class AddItemScreen extends StatefulWidget {
  final Function(InvoiceLineItem) onSave;
  const AddItemScreen({super.key, required this.onSave});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _rateController = TextEditingController();
  final _nameFocusNode = FocusNode();

  String _selectedUnit = 'Nos';
  String _taxType = 'Without Tax';

  // --- NEW: Add a saving flag ---
  bool _isSaving = false;

  void _showUnitSelectionDialog() async {
    // ... (dialog logic remains the same)
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const UnitSelectionDialog(),
    );

    if (result != null) {
      setState(() {
        _selectedUnit = result;
      });
    }
  }

  // --- MODIFIED SAVE FUNCTION ---
  void _saveItem({bool saveAndNew = false}) {
    // Exit if already saving or form is invalid
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    // --- Start saving ---
    setState(() {
      _isSaving = true;
    });

    try {
      final newItem = InvoiceLineItem(
        name: _nameController.text.isNotEmpty ? _nameController.text : 'Item',
        quantity: double.tryParse(_qtyController.text) ?? 1.0,
        rate: double.tryParse(_rateController.text) ?? 0.0,
        unit: _selectedUnit,
        taxType: _taxType,
      );

      // Call the callback provided by the parent screen
      widget.onSave(newItem);

      // Handle navigation or reset based on the button pressed
      if (saveAndNew) {
        // Reset form fields
        _formKey.currentState!.reset();
        _nameController.clear();
        _qtyController.text = '1';
        _rateController.clear();
        setState(() {
          _selectedUnit = 'Nos';
          _taxType = 'Without Tax';
        });
        // Request focus back to the name field for quick entry
        _nameFocusNode.requestFocus();
      } else {
        // Close the AddItemScreen
        if (mounted) { // Check if the widget is still in the tree
           Navigator.pop(context);
        }
      }
    } catch (e) {
       // Handle potential errors during onSave callback or state updates
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text('Error processing item: $e')),
          );
       }
    } finally {
      // --- Finish saving, re-enable buttons ---
      // Use mounted check before calling setState if the operation could be long
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
  // --- END MODIFIED SAVE FUNCTION ---

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          // Form fields remain mostly the same...
          child: Column(
            children: [
               TextFormField(
                controller: _nameController, // Assign controller
                focusNode: _nameFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Item Name',
                  hintText: 'e.g. Chocolate Cake',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  // Keep validator, or adjust if empty names are allowed ('Item')
                  // if (value == null || value.isEmpty) {
                  //   return 'Please enter an item name';
                  // }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController, // Assign controller
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                       validator: (value) { // Add basic validation
                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                          return 'Enter valid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _isSaving ? null : _showUnitSelectionDialog, // Disable tap during save
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_selectedUnit),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rateController, // Assign controller
                      decoration: const InputDecoration(
                        labelText: 'Rate (Price/Unit)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) { // Add basic validation
                        if (value == null || value.isEmpty || double.tryParse(value) == null) {
                          return 'Enter valid rate';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _taxType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ['With Tax', 'Without Tax']
                          .map((label) => DropdownMenuItem(
                                value: label,
                                child: Text(label),
                              ))
                          .toList(),
                      onChanged: _isSaving ? null : (value) { // Disable during save
                        if (value != null) {
                          setState(() {
                            _taxType = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                // --- Disable button when saving ---
                onPressed: _isSaving ? null : () => _saveItem(saveAndNew: true),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save & New'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                // --- Disable button when saving ---
                onPressed: _isSaving ? null : () => _saveItem(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                ),
                child: _isSaving
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}