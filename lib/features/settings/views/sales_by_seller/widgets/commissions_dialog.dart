import 'package:flutter/material.dart';
import 'package:oftal_web/core/theme/app_colors.dart';
import 'package:oftal_web/shared/extensions/extensions.dart';

class CommissionsDialog extends StatefulWidget {
  const CommissionsDialog({super.key, required this.sellerTotals});

  /// seller name -> total sales amount
  final Map<String, double> sellerTotals;

  @override
  State<CommissionsDialog> createState() => CommissionsDialogState();
}

class CommissionsDialogState extends State<CommissionsDialog> {
  final _controller = TextEditingController();
  Map<String, double>? _commissions;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _calculate() {
    final text = _controller.text.trim().replaceAll(',', '.');
    final pct = double.tryParse(text);
    if (pct == null || pct <= 0) {
      setState(() {
        _error = 'Ingresa un porcentaje v\u00e1lido mayor a 0';
        _commissions = null;
      });
      return;
    }
    setState(() {
      _error = null;
      _commissions = widget.sellerTotals.map(
        (seller, total) => MapEntry(seller, total * pct / 100),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              // ── Title ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calculate_outlined,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(
                          'C\u00e1lculo de comisiones',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.zinc900,
                          ),
                        ),
                        Text(
                          'Ingresa el porcentaje para calcular',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.zinc500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: AppColors.zinc200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Seller totals ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.zinc200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: widget.sellerTotals.entries.map((e) {
                    final isLast =
                        e.key == widget.sellerTotals.keys.last;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                bottom: BorderSide(
                                  color: AppColors.zinc100,
                                ),
                              ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.zinc900,
                              ),
                            ),
                          ),
                          Text(
                            e.value.toCurrency(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.zinc600,
                            ),
                          ),
                          if (_commissions != null) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.successBg,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                (_commissions![e.key] ?? 0).toCurrency(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.successDark,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // ── Percentage input + button ──────────────────────
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        TextField(
                          controller: _controller,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Ej: 1.2',
                            suffixText: '%',
                            errorText: _error,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.zinc200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.zinc200,
                              ),
                            ),
                          ),
                          onSubmitted: (_) => _calculate(),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Calcular',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
