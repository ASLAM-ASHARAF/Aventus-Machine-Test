import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';




class RebuildCounter extends StatefulWidget {
  const RebuildCounter({
    super.key,
    required this.label,
    required this.token,
  });

  final String label;
  final Object? token;

  @override
  State<RebuildCounter> createState() => _RebuildCounterState();
}

class _RebuildCounterState extends State<RebuildCounter> {
  int _buildCount = 0;

  @override
  Widget build(BuildContext context) {
    _buildCount++;
    if (kDebugMode) {
      debugPrint('🔁 [${widget.label}] rebuilt $_buildCount time(s)');
    }

   
   
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: const BoxDecoration(
        color: Color(0xCC263238),
        borderRadius: BorderRadius.all(Radius.circular(999)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.refresh, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '${widget.label} · $_buildCount',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
