import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/shared/models/entities/entities.dart';
import 'package:pos/features/inventory/presentation/controllers/inventory_controller.dart';

class LocationDropdown extends StatefulWidget {
  final String? selectedLocationId;
  final Function(String?) onLocationSelected;
  final String? label;
  final bool enabled;

  const LocationDropdown({
    super.key,
    this.selectedLocationId,
    required this.onLocationSelected,
    this.label,
    this.enabled = true,
  });

  @override
  State<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  String? _selectedLocationId;
  List<Location> _locations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLocationId = widget.selectedLocationId;
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (Get.isRegistered<InventoryController>()) {
        final inventoryController = Get.find<InventoryController>();
        _locations = inventoryController.locations;
      }
    } catch (e) {
      print('Error loading locations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Location? get _selectedLocation {
    if (_selectedLocationId == null) return null;
    try {
      return _locations.firstWhere((l) => l.id == _selectedLocationId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedLocationId,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: InputBorder.none,
            ),
            hint: Text(_isLoading ? 'Loading locations...' : 'Select Location'),
            isExpanded: true,
            items: _locations.map((location) {
              return DropdownMenuItem<String>(
                value: location.id,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          location.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (location.isPrimary) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PRIMARY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Type: ${location.type} | Address: ${location.address ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              setState(() {
                _selectedLocationId = value;
              });
              widget.onLocationSelected(value);
            },
          ),
        ),
        if (_selectedLocation != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Location:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedLocation!.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Type: ${_selectedLocation!.type} | Address: ${_selectedLocation!.address ?? 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
