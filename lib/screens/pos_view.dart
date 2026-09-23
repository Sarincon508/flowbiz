import 'package:flutter/material.dart';
import '../models/business_models.dart';
import '../providers/flowbiz_controller.dart';
import '../theme/app_theme.dart';

class PosView extends StatefulWidget {
  final FlowBizController controller;

  const PosView({super.key, required this.controller});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  String _searchQuery = '';
  String _selectedCategory = 'Todos';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.controller;

    // Categories: 'Todos' + categories from controller
    final categories = ['Todos', ...controller.categories];

    // Filter items
    final filtered = controller.catalog.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCat = _selectedCategory == 'Todos' || item.category == _selectedCategory;
      return matchesSearch && matchesCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punto de Venta (POS)'),
        actions: [
          // Gestionar Categorías
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Gestionar Categorías',
            onPressed: () => _showManageCategoriesDialog(context),
          ),
          // Nuevo Producto / Servicio
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Nuevo Producto / Servicio',
            onPressed: () => _showAddProductDialog(context),
          ),
          // Cart Button in AppBar (Intuitivo)
          IconButton(
            icon: Badge(
              isLabelVisible: controller.cartCount > 0,
              label: Text('${controller.cartCount}'),
              backgroundColor: AppTheme.accent,
              child: const Icon(Icons.shopping_cart_rounded),
            ),
            tooltip: 'Ver Carrito de Venta',
            onPressed: () => _showCheckoutModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar en catálogo...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Categories Bar (Selectable, addable, deletable)
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                if (idx == categories.length) {
                  // Button to add category
                  return ActionChip(
                    avatar: const Icon(Icons.add, size: 16, color: AppTheme.primary),
                    label: const Text('Nueva Categoría', style: TextStyle(color: AppTheme.primary)),
                    onPressed: () => _showAddCategoryDialog(context),
                  );
                }

                final cat = categories[idx];
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Catalog Grid
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 54, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
                        const SizedBox(height: 10),
                        Text(
                          'No hay productos o servicios en esta sección',
                          style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Crear Ítem'),
                          onPressed: () => _showAddProductDialog(context),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.84,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, idx) {
                      final item = filtered[idx];
                      return _CatalogItemCard(
                        item: item,
                        formattedPrice: controller.formatMoney(item.price),
                        onAdd: () => controller.addToCart(item),
                        onDelete: () => _confirmDeleteItem(context, item),
                      );
                    },
                  ),
          ),
        ],
      ),

      // Prominent Floating Cart Bar at Bottom (Super intuitivo)
      bottomSheet: controller.cart.isEmpty
          ? null
          : Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showCheckoutModal(context),
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${controller.cartCount} ${controller.cartCount == 1 ? "ítem seleccionado" : "ítems seleccionados"}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                controller.formatMoney(controller.cartTotal),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Cobrar',
                                style: TextStyle(color: AppTheme.primaryDark, fontWeight: FontWeight.w800, fontSize: 13),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_rounded, color: AppTheme.primaryDark, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  void _confirmDeleteItem(BuildContext context, ProductService item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar del catálogo?'),
        content: Text('¿Estás seguro de que deseas eliminar "${item.name}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              await widget.controller.deleteProduct(item.id);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Se eliminó "${item.name}" del catálogo.')),
                );
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva Categoría'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Nombre de la categoría',
            hintText: 'ej: Tratamientos, Barbería, Bebidas',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              final ok = await widget.controller.addCategory(name);
              if (ctx.mounted) Navigator.pop(ctx);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La categoría ya existe o es inválida.')),
                );
              }
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showManageCategoriesDialog(BuildContext context) {
    final newCatCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDlgState) {
            final categories = widget.controller.categories;
            return AlertDialog(
              title: const Text('Gestionar Categorías'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Inline input to add category
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newCatCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Nueva categoría...',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Agregar'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          onPressed: () async {
                            final name = newCatCtrl.text.trim();
                            if (name.isNotEmpty) {
                              final ok = await widget.controller.addCategory(name);
                              if (ok) {
                                newCatCtrl.clear();
                                setDlgState(() {});
                              } else {
                                if (ctx.mounted) {
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    const SnackBar(content: Text('La categoría ya existe o es inválida.')),
                                  );
                                }
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 8),

                    // Categories list
                    Flexible(
                      child: categories.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text('No hay categorías creadas.'),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: categories.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, i) {
                                final cat = categories[i];
                                final count = widget.controller.catalog
                                    .where((p) => p.category.toLowerCase() == cat.toLowerCase())
                                    .length;
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(cat, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  subtitle: Text('$count ${count == 1 ? "ítem" : "ítems"} asociados'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 20),
                                    tooltip: 'Eliminar categoría',
                                    onPressed: () async {
                                      final deleted = await widget.controller.deleteCategory(cat);
                                      if (!deleted) {
                                        if (ctx.mounted) {
                                          showDialog(
                                            context: ctx,
                                            builder: (alertCtx) => AlertDialog(
                                              title: const Text('No se puede eliminar'),
                                              content: Text(
                                                'La categoría "$cat" no está vacía ($count productos/servicios asociados). '
                                                'Debes eliminar o mover sus productos antes de borrar la categoría.',
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(alertCtx),
                                                  child: const Text('Entendido'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      } else {
                                        setDlgState(() {});
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
              ],
            );
          },
        );
      },
    );
  }

  void _showCheckoutModal(BuildContext context) {
    final controller = widget.controller;
    PaymentMethod selectedMethod = PaymentMethod.cash;
    final clientCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    final cashGivenCtrl = TextEditingController();
    double discountAmount = 0.0;
    double changeAmount = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final subtotal = controller.cartTotal;
            final total = (subtotal - discountAmount).clamp(0.0, double.infinity);

            void updateChange(String val) {
              final parsed = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              setModalState(() {
                changeAmount = parsed > total ? parsed - total : 0;
              });
            }

            return Container(
              height: MediaQuery.of(ctx).size.height * 0.88,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Detalle del Carrito',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      if (controller.cart.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            controller.clearCart();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Vaciar Carrito', style: TextStyle(color: AppTheme.error)),
                        ),
                    ],
                  ),
                  const Divider(),

                  // Item list
                  Expanded(
                    child: controller.cart.isEmpty
                        ? const Center(
                            child: Text('El carrito está vacío. Agrega productos o servicios desde el catálogo.'),
                          )
                        : ListView.separated(
                            itemCount: controller.cart.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final item = controller.cart[idx];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(controller.formatMoney(item.product.price)),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                                      onPressed: () {
                                        controller.updateCartQuantity(item.product.id, -1);
                                        setModalState(() {
                                          updateChange(cashGivenCtrl.text);
                                        });
                                        if (controller.cart.isEmpty) Navigator.pop(ctx);
                                      },
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20),
                                      onPressed: () {
                                        controller.updateCartQuantity(item.product.id, 1);
                                        setModalState(() {
                                          updateChange(cashGivenCtrl.text);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  if (controller.cart.isNotEmpty) ...[
                    const Divider(),

                    // Client & Discount
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: clientCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Cliente (Opcional)',
                              prefixIcon: Icon(Icons.person_outline),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: discountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Descuento (\$)',
                              prefixIcon: Icon(Icons.discount_outlined),
                              isDense: true,
                            ),
                            onChanged: (val) {
                              final p = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                              setModalState(() {
                                discountAmount = p;
                                updateChange(cashGivenCtrl.text);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    const Text('Método de Pago:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: PaymentMethod.values.map((method) {
                        final isSel = selectedMethod == method;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                method == PaymentMethod.transfer ? 'Digital' : method.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  color: isSel ? Colors.white : null,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: AppTheme.primary,
                              onSelected: (s) {
                                if (s) setModalState(() => selectedMethod = method);
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    // Cash Calculator if Cash
                    if (selectedMethod == PaymentMethod.cash) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: cashGivenCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Efectivo recibido (\$)',
                                prefixIcon: Icon(Icons.monetization_on_outlined),
                              ),
                              onChanged: updateChange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Cambio / Vueltos', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                                Text(
                                  controller.formatMoney(changeAmount),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Desglose si hay descuento
                    if (discountAmount > 0) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                          Text(controller.formatMoney(subtotal), style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Descuento aplicado:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.error)),
                          Text('- ${controller.formatMoney(discountAmount)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.error)),
                        ],
                      ),
                      const SizedBox(height: 6),
                    ],

                    // Total & Confirm Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total a Cobrar:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(
                          controller.formatMoney(total),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final nav = Navigator.of(ctx);
                          final sm = ScaffoldMessenger.of(context);
                          await controller.completePosSale(
                            selectedMethod,
                            clientName: clientCtrl.text.trim(),
                            discountAmount: discountAmount,
                          );
                          nav.pop();
                          sm.showSnackBar(
                            const SnackBar(
                              content: Text('¡Venta registrada con éxito en caja!'),
                              backgroundColor: AppTheme.accent,
                            ),
                          );
                        },
                        child: const Text('Confirmar Cobro e Ingresar a Caja'),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String selectedCat = widget.controller.categories.isNotEmpty ? widget.controller.categories.first : 'Servicios';
    bool isService = true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Nuevo Producto / Servicio'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre del ítem *'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Precio (\$) *'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedCat,
                      decoration: const InputDecoration(labelText: 'Categoría'),
                      items: widget.controller.categories.map((c) {
                        return DropdownMenuItem(value: c, child: Text(c));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedCat = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('¿Es un Servicio?'),
                      subtitle: Text(isService ? 'Se puede agendar en citas' : 'Producto de venta física'),
                      value: isService,
                      onChanged: (v) => setDialogState(() => isService = v),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
                    if (name.isEmpty || price <= 0) return;

                    widget.controller.addProduct(
                      ProductService(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: name,
                        price: price,
                        category: selectedCat,
                        isService: isService,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _CatalogItemCard extends StatelessWidget {
  final ProductService item;
  final String formattedPrice;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const _CatalogItemCard({
    required this.item,
    required this.formattedPrice,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: InkWell(
        onTap: onAdd,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: item.isService
                          ? AppTheme.primary.withValues(alpha: 0.15)
                          : AppTheme.warning.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item.isService ? 'Servicio' : 'Producto',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: item.isService ? AppTheme.primary : AppTheme.warning,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Delete item button
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFF94A3B8)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 16, color: AppTheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Text(
                formattedPrice,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: isDark ? AppTheme.primaryLight : AppTheme.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
