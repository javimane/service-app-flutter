import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppDropdownItem<T> {
  final T value;
  final String label;

  const AppDropdownItem({required this.value, required this.label});
}

class AppDropdown<T> extends StatelessWidget {
  final T? value;
  final List<AppDropdownItem<T>> items;
  final void Function(T) onChanged;
  final String hint;
  final bool isExpanded;
  final Widget? icon;

  const AppDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = '',
    this.isExpanded = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    AppDropdownItem<T>? selectedItem;
    try {
      if (value != null) {
        selectedItem = items.firstWhere((i) => i.value == value);
      }
    } catch (_) {
      selectedItem = null;
    }

    final content = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            selectedItem?.label ?? hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14.sp,
              color: selectedItem != null
                  ? (isDark ? Colors.white : Colors.black)
                  : Colors.grey,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        icon ?? Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 20.r),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return PopupMenuButton<T>(
          initialValue: value,
          onSelected: onChanged,
          position: PopupMenuPosition.under,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          color: theme.colorScheme.surface,
          elevation: 6,
          offset: Offset(0, 8.h),
          constraints: BoxConstraints(
            minWidth: constraints.maxWidth,
            maxWidth: constraints.maxWidth,
          ),
          itemBuilder: (context) {
            return items.map((item) {
              final isSelected = item.value == value;
              return PopupMenuItem<T>(
                value: item.value,
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withAlpha(20)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? theme.colorScheme.primary : null,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, 
                             color: theme.colorScheme.primary, 
                             size: 18.r),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: isDark ? Colors.white24 : Colors.black12),
            ),
            child: content,
          ),
        );
      }
    );
  }
}
