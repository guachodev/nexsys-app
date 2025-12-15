import 'package:flutter/material.dart';

class DropdownItem {
  final int value;
  final String text;

  const DropdownItem({required this.value, required this.text});

  @override
  String toString() => text;
}

class CustomDropdownFormField extends StatefulWidget {
  final String label;
  final String? hint;
  final bool isRequired;
  final DropdownItem? selectedItem;
  final List<DropdownItem> items;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    this.hint,
    this.isRequired = false,
    this.selectedItem,
    required this.items,
  });

  @override
  State<CustomDropdownFormField> createState() =>
      _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  @override
  Widget build(BuildContext context) {
    return FormField(
      builder: (FormFieldState<dynamic> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                if (widget.isRequired)
                  Text(' *', style: TextStyle(color: Colors.red, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _showBottomSheet,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: state.hasError ? Colors.red : Colors.grey[300]!,
                    width: state.hasError ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.selectedItem?.text ??
                            widget.hint ??
                            'Selecciona una opción',
                        style: TextStyle(
                          fontSize: 16,
                          color: widget.selectedItem == null
                              ? Colors.grey[500]
                              : Colors.grey[800],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      color: Colors.grey[500],
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
      //validator: widget.,
    );
  }

  void _showBottomSheet() {
    FocusScope.of(context).unfocus(); // Cierra el teclado si está abierto

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheetContent(),
    );
  }

  Widget _buildBottomSheetContent() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!, width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey[500],
                ),
              ],
            ),
          ),

          // Lista de opciones
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                final isSelected = widget.selectedItem?.value == item.value;

                return ListTile(
                  /* onTap: () {
                    widget.onChanged(item);
                    Navigator.pop(context);
                  }, */
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                          )
                        : null,
                  ),
                  title: Text(
                    item.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[800],
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          color: Theme.of(context).primaryColor,
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
