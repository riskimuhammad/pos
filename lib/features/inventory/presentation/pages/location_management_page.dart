import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/features/inventory/presentation/controllers/location_controller.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/core/theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocationManagementPage extends StatelessWidget {
  const LocationManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LocationController>();

    return WillPopScope(
      onWillPop: () async {
        // Return true to indicate that data might have changed
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.manageLocations),
          backgroundColor: AppTheme.primaryColor,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppTheme.primaryColor,
          onPressed: () => _showCreateDialog(context, controller),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          }

          if (controller.locations.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.noLocations),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.locations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final loc = controller.locations[index];
              return Card(
                child: ListTile(
                  title: Text(loc.name),
                  subtitle: Text('${_getLocationTypeName(loc.type, context)}${loc.isPrimary ? ' • ${AppLocalizations.of(context)!.primaryLocation}' : ''}${!loc.isActive ? ' • ${AppLocalizations.of(context)!.inactive}' : ''}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      switch (value) {
                        case 'edit':
                          _showEditDialog(context, controller, loc);
                          break;
                        case 'primary':
                          await controller.setPrimary(loc.id);
                          break;
                        case 'toggle':
                          await controller.toggleActive(loc);
                          break;
                        case 'delete':
                          await controller.deleteLocation(loc.id);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(value: 'edit', child: Text(AppLocalizations.of(context)!.edit)),
                      PopupMenuItem(value: 'primary', child: Text(AppLocalizations.of(context)!.setAsPrimary)),
                      PopupMenuItem(value: 'toggle', child: Text('${AppLocalizations.of(context)!.active}/${AppLocalizations.of(context)!.inactive}')),
                      PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context)!.delete)),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  String _getLocationTypeName(String type, BuildContext context) {
    switch (type.toLowerCase()) {
      case 'store':
      case 'toko':
        return AppLocalizations.of(context)!.locationTypeToko;
      case 'warehouse':
      case 'gudang':
        return AppLocalizations.of(context)!.locationTypeGudang;
      case 'shelf':
      case 'rak':
        return AppLocalizations.of(context)!.locationTypeRak;
      case 'area':
        return AppLocalizations.of(context)!.locationTypeArea;
      default:
        return type;
    }
  }

  void _showCreateDialog(BuildContext context, LocationController controller) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String selectedType = 'toko';
    bool isPrimary = false;
    bool isActive = true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addLocation),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl, 
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.locationName,
                  hintText: AppLocalizations.of(context)!.locationNameHint,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.locationType),
                items: [
                  DropdownMenuItem(value: 'toko', child: Text(AppLocalizations.of(context)!.locationTypeToko)),
                  DropdownMenuItem(value: 'gudang', child: Text(AppLocalizations.of(context)!.locationTypeGudang)),
                  DropdownMenuItem(value: 'rak', child: Text(AppLocalizations.of(context)!.locationTypeRak)),
                  DropdownMenuItem(value: 'area', child: Text(AppLocalizations.of(context)!.locationTypeArea)),
                ],
                onChanged: (value) => selectedType = value ?? 'toko',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressCtrl, 
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.locationAddress,
                  hintText: AppLocalizations.of(context)!.locationAddressHint,
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Checkbox(value: isPrimary, onChanged: (v){ isPrimary = v ?? false; }),
                Text(AppLocalizations.of(context)!.setAsPrimary),
              ]),
              Row(children: [
                Checkbox(value: isActive, onChanged: (v){ isActive = v ?? true; }),
                Text(AppLocalizations.of(context)!.active),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: ()=> Get.back(), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) {
                Get.snackbar('Error', AppLocalizations.of(context)!.locationNameRequired);
                return;
              }
              await controller.createLocation(
                name: nameCtrl.text,
                type: selectedType,
                address: addressCtrl.text.isEmpty ? null : addressCtrl.text,
                isPrimary: isPrimary,
                isActive: isActive,
              );
              Get.back();
            },
            child: Text(AppLocalizations.of(context)!.save),
          )
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, LocationController controller, Location loc) {
    final nameCtrl = TextEditingController(text: loc.name);
    final addressCtrl = TextEditingController(text: loc.address ?? '');
    
    // Ensure the type is one of the valid options
    String selectedType = loc.type;
    if (!['toko', 'gudang', 'rak', 'area'].contains(selectedType)) {
      selectedType = 'toko'; // Default fallback
    }
    
    bool isPrimary = loc.isPrimary;
    bool isActive = loc.isActive;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editLocation),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl, 
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.locationName,
                  hintText: AppLocalizations.of(context)!.locationNameHint,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: InputDecoration(labelText: AppLocalizations.of(context)!.locationType),
                items: [
                  DropdownMenuItem(value: 'toko', child: Text(AppLocalizations.of(context)!.locationTypeToko)),
                  DropdownMenuItem(value: 'gudang', child: Text(AppLocalizations.of(context)!.locationTypeGudang)),
                  DropdownMenuItem(value: 'rak', child: Text(AppLocalizations.of(context)!.locationTypeRak)),
                  DropdownMenuItem(value: 'area', child: Text(AppLocalizations.of(context)!.locationTypeArea)),
                ],
                onChanged: (value) => selectedType = value ?? 'toko',
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressCtrl, 
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.locationAddress,
                  hintText: AppLocalizations.of(context)!.locationAddressHint,
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Checkbox(value: isPrimary, onChanged: (v){ isPrimary = v ?? false; }),
                Text(AppLocalizations.of(context)!.setAsPrimary),
              ]),
              Row(children: [
                Checkbox(value: isActive, onChanged: (v){ isActive = v ?? true; }),
                Text(AppLocalizations.of(context)!.active),
              ]),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: ()=> Get.back(), child: Text(AppLocalizations.of(context)!.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) {
                Get.snackbar('Error', AppLocalizations.of(context)!.locationNameRequired);
                return;
              }
              final updated = loc.copyWith(
                name: nameCtrl.text.trim().isEmpty ? loc.name : nameCtrl.text.trim(),
                type: selectedType,
                address: addressCtrl.text.trim().isEmpty ? loc.address : addressCtrl.text.trim(),
                isPrimary: isPrimary,
                isActive: isActive,
              );
              await controller.updateLocation(updated);
              Get.back();
            },
            child: Text(AppLocalizations.of(context)!.save),
          )
        ],
      ),
    );
  }
}