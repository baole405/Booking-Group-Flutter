import 'package:booking_group_flutter/models/major.dart';
import 'package:booking_group_flutter/resources/major_api.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for selecting a major
class MajorSelectorBottomSheet extends StatefulWidget {
  final Major? currentMajor;

  const MajorSelectorBottomSheet({super.key, this.currentMajor});

  @override
  State<MajorSelectorBottomSheet> createState() =>
      _MajorSelectorBottomSheetState();
}

class _MajorSelectorBottomSheetState extends State<MajorSelectorBottomSheet> {
  final MajorApi _majorApi = MajorApi();

  List<Major> _majors = [];
  bool _isLoading = true;
  String? _error;
  Major? _selectedMajor;

  @override
  void initState() {
    super.initState();
    _selectedMajor = widget.currentMajor;
    _loadMajors();
  }

  Future<void> _loadMajors() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final majors = await _majorApi.getAllMajors();
      setState(() {
        _majors = majors;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const Expanded(
                  child: Text(
                    'Chọn chuyên ngành',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance the close button
              ],
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadMajors,
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : _majors.isEmpty
                ? const Center(
                    child: Text(
                      'Không có chuyên ngành nào',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _majors.length,
                    itemBuilder: (context, index) {
                      final major = _majors[index];
                      final isSelected = _selectedMajor?.id == major.id;

                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.blue.shade100
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.school,
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.grey.shade600,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          major.name,
                          style: TextStyle(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? Colors.blue.shade700
                                : Colors.black87,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: Colors.blue.shade700,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedMajor = major;
                          });
                        },
                      );
                    },
                  ),
          ),

          // Bottom button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedMajor == null
                      ? null
                      : () {
                          Navigator.pop(context, _selectedMajor);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text(
                    'Xác nhận',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the major selector bottom sheet
Future<Major?> showMajorSelector(
  BuildContext context, {
  Major? currentMajor,
}) async {
  return showModalBottomSheet<Major>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => MajorSelectorBottomSheet(currentMajor: currentMajor),
  );
}
