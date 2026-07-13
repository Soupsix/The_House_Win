import 'package:flutter/material.dart';
import '../../../domain/models/slot_symbol_model.dart';

class SlotReelWidget extends StatefulWidget {
  final List<SlotSymbolModel> allSymbols;
  final bool isSpinning;
  final String? targetSymbolId;
  final int stopDelayMs;
  final VoidCallback? onAnimationComplete;

  const SlotReelWidget({
    super.key,
    required this.allSymbols,
    required this.isSpinning,
    this.targetSymbolId,
    required this.stopDelayMs,
    this.onAnimationComplete,
  });

  @override
  State<SlotReelWidget> createState() => _SlotReelWidgetState();
}

class _SlotReelWidgetState extends State<SlotReelWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late FixedExtentScrollController _scrollController;
  final int _itemExtent = 80; // Height of each symbol
  bool _isStopping = false;

  @override
  void initState() {
    super.initState();
    _scrollController = FixedExtentScrollController(initialItem: 0);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _controller.addListener(() {
      if (_scrollController.hasClients) {
        // Continuous scroll down
        _scrollController.jumpTo(_scrollController.offset + 15);
      }
    });
  }

  @override
  void didUpdateWidget(SlotReelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSpinning && !oldWidget.isSpinning) {
      // Start spinning
      _isStopping = false;
      _controller.repeat();
    } else if (widget.isSpinning && widget.targetSymbolId != null && oldWidget.targetSymbolId == null && !_isStopping) {
      // Stop spinning
      _stopAtTarget();
    }
  }

  Future<void> _stopAtTarget() async {
    _isStopping = true;
    
    // Stagger delay
    await Future.delayed(Duration(milliseconds: widget.stopDelayMs));

    if (!mounted) return;
    
    _controller.stop();

    // Find index of target
    final targetIndex = widget.allSymbols.indexWhere((s) => s.id == widget.targetSymbolId);
    if (targetIndex != -1) {
      // We will jump to a very high item index that modulo length is targetIndex
      // to simulate stopping naturally
      final currentItem = _scrollController.selectedItem;
      const jumps = 10; // Extra full rotations before stopping
      final nextStop = currentItem + (widget.allSymbols.length - (currentItem % widget.allSymbols.length)) + targetIndex + (jumps * widget.allSymbols.length);
      
      await _scrollController.animateToItem(
        nextStop,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOutQuad,
      );
    }
    
    widget.onAnimationComplete?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 240, // Shows exactly 3 symbols visible
      decoration: BoxDecoration(
        color: const Color(0xFF1E2030),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E3050), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
            blurStyle: BlurStyle.inner,
          ),
        ],
      ),
      child: ListWheelScrollView.useDelegate(
        controller: _scrollController,
        itemExtent: _itemExtent.toDouble(),
        physics: const NeverScrollableScrollPhysics(), // Only controlled programmatically
        perspective: 0.001,
        diameterRatio: 2.5,
        overAndUnderCenterOpacity: 0.6,
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final symbolIndex = index % widget.allSymbols.length;
            final symbol = widget.allSymbols[symbolIndex];
            
            return Center(
              child: Image.asset(
                symbol.iconAsset,
                width: 60,
                height: 60,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image is missing
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.primaries[symbol.id.hashCode % Colors.primaries.length].withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        symbol.id.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
