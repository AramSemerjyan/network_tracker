import 'package:flutter/material.dart';
import 'package:network_tracker/src/model/network_reuqest_filter.dart';

import '../../model/network_request_method.dart';
import '../../services/request_status.dart';
import 'filter_card.dart';

class FilterBar extends StatelessWidget {
  final NetworkRequestFilter filter;
  final Function(NetworkRequestFilter)? onChange;
  final VoidCallback? onClear;

  const FilterBar({
    super.key,
    required this.filter,
    this.onChange,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                FilterCard<NetworkRequestMethod>(
                  title: 'Method',
                  value: filter.method,
                  options: NetworkRequestMethod.values,
                  getLabel: (v) => v.value,
                  onChanged: (v) => onChange?.call(filter.copy(method: v)),
                ),
                const SizedBox(width: 8),
                FilterCard<RequestStatus>(
                  title: 'Status',
                  value: filter.status,
                  options: RequestStatus.values,
                  getLabel: (v) => v.name,
                  onChanged: (v) => onChange?.call(filter.copy(status: v)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onClear,
            child: Text(
              'Clear',
            ),
          ),
        ],
      ),
    );
  }
}
