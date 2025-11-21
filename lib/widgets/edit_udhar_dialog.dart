import 'package:flutter/material.dart';

/// Result returned from the EditUdharDialog:
/// - [adjustment]: signed value (+ => receive more, - => pay more)
/// - [description]: updated description string
class UdharAdjustmentResult {
  final double adjustment;
  final String description;

  UdharAdjustmentResult({required this.adjustment, required this.description});
}

class EditUdharDialog extends StatefulWidget {
  final String title;
  final double currentAmount;
  final bool isGive;
  final String initialDescription;

  const EditUdharDialog({
    super.key,
    required this.title,
    required this.currentAmount,
    required this.isGive,
    required this.initialDescription,
  });

  @override
  State<EditUdharDialog> createState() => _EditUdharDialogState();
}

class _EditUdharDialogState extends State<EditUdharDialog> {
  String input = '';
  double runningAdjustment = 0.0; // accumulated adjustment
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  double parseInput() {
    if (input.isEmpty) return 0.0;
    if (input == '.' || input == '-') return 0.0;
    return double.tryParse(input) ?? 0.0;
  }

  void appendChar(String c) {
    if (c == '.' && input.contains('.')) return;
    if (input == '0' && c != '.') {
      input = c;
    } else {
      input = input + c;
    }
  }

  void onBackspace() {
    if (input.isEmpty) return;
    input = input.substring(0, input.length - 1);
  }

  void onClear() {
    input = '';
  }

  void applyAdjustment(int sign) {
    final typedValue = parseInput();
    if (typedValue == 0.0) return;
    setState(() {
      runningAdjustment += sign * typedValue;
      input = ''; // clear after applying
    });
  }

  Widget keypadButton(String label, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            elevation: 0,
          ),
          onPressed: onTap,
          child: Text(
            label,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typedValue = parseInput();

    return AlertDialog(
      title: Text('Adjust Amount — ${widget.title}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Current: ₹ ${widget.currentAmount.toStringAsFixed(0)} '
                '(${widget.isGive ? "To Pay" : "To Receive"})',
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),

            // 🔹 Description edit field
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),

            const SizedBox(height: 10),

            // Display typed value
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: Text(
                      'Typed: ${typedValue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Accumulated adjustment preview
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey.shade100,
                    ),
                    child: Text(
                      'Total adjustment: '
                      '${runningAdjustment >= 0 ? "+" : "-"} '
                      '₹ ${runningAdjustment.abs().toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // + and - APPLY buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      applyAdjustment(1); // Add
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      applyAdjustment(-1); // Deduct
                    },
                    icon: const Icon(Icons.remove),
                    label: const Text('Deduct'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Keypad
            Column(
              children: [
                Row(
                  children: [
                    keypadButton('1', () => setState(() => appendChar('1'))),
                    keypadButton('2', () => setState(() => appendChar('2'))),
                    keypadButton('3', () => setState(() => appendChar('3'))),
                  ],
                ),
                Row(
                  children: [
                    keypadButton('4', () => setState(() => appendChar('4'))),
                    keypadButton('5', () => setState(() => appendChar('5'))),
                    keypadButton('6', () => setState(() => appendChar('6'))),
                  ],
                ),
                Row(
                  children: [
                    keypadButton('7', () => setState(() => appendChar('7'))),
                    keypadButton('8', () => setState(() => appendChar('8'))),
                    keypadButton('9', () => setState(() => appendChar('9'))),
                  ],
                ),
                Row(
                  children: [
                    keypadButton('.', () => setState(() => appendChar('.'))),
                    keypadButton('0', () => setState(() => appendChar('0'))),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                          ),
                          onPressed: () => setState(onBackspace),
                          child: const Icon(Icons.backspace_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            onClear();
                            runningAdjustment = 0.0;
                          });
                        },
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Builder(
                        builder: (dialogContext) => ElevatedButton(
                          onPressed: () {
                            double totalAdj = runningAdjustment;
                            if (typedValue != 0.0) {
                              totalAdj += typedValue;
                            }
                            Navigator.of(dialogContext).pop(
                              UdharAdjustmentResult(
                                adjustment: totalAdj,
                                description: _descController.text.trim(),
                              ),
                            );
                          },
                          child: const Text('Confirm'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
