import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';
import '../model/cylinder_make_model.dart';

class HomeSectionHeader extends StatelessWidget {
  final String title;
  const HomeSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.light
            ? const Color(0xFF2E3192)
            : theme.cardColor,
        border: const Border(
          left: BorderSide(color: AppColors.secondary, width: 5),
        ),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class HomeSectionTitle extends StatelessWidget {
  final String title;
  const HomeSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class HomeRowLabels extends StatelessWidget {
  final String l1;
  final String l2;
  const HomeRowLabels({super.key, required this.l1, required this.l2});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8);
    return Row(
      children: [
        Expanded(
          child: Text(
            l1,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Text(
            l2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class HomeValueBox extends StatelessWidget {
  final String text;
  const HomeValueBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}

class HomeManualField extends StatelessWidget {
  final String hint;
  final int maxLines;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final IconData? icon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final void Function(String)? onFieldSubmitted;
  final FocusNode? focusNode;

  const HomeManualField({
    super.key,
    required this.hint,
    this.maxLines = 1,
    this.controller,
    this.validator,
    this.keyboardType,
    this.onChanged,
    this.icon,
    this.inputFormatters,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.onFieldSubmitted,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      validator: validator,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      inputFormatters: inputFormatters,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      style: TextStyle(fontSize: 13, color: theme.textTheme.bodyLarge?.color),
      decoration: InputDecoration(
        hintText: hint,
        counterText: "",
        hintStyle: TextStyle(
          fontSize: 12,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
        ),
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: theme.colorScheme.primary)
            : null,
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        border: theme.inputDecorationTheme.border,
        enabledBorder: theme.inputDecorationTheme.enabledBorder,
        focusedBorder: theme.inputDecorationTheme.focusedBorder,
        errorBorder: theme.inputDecorationTheme.errorBorder,
        focusedErrorBorder: theme.inputDecorationTheme.focusedErrorBorder,
      ),
    );
  }
}

class HomeDatePickerField extends StatelessWidget {
  final String label;
  final String? displayDate;
  final VoidCallback onTap;
  final String? Function(String?)? validator;
  final bool showIcon;
  const HomeDatePickerField({
    super.key,
    required this.label,
    this.displayDate,
    required this.onTap,
    this.validator,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormField<String>(
      validator: validator,
      initialValue: displayDate,
      builder: (FormFieldState<String> state) {
        final date = displayDate ?? label;
        final hasError = state.hasError;

        return GestureDetector(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasError ? Colors.red : theme.dividerColor,
                    width: hasError ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        date,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: displayDate == null
                              ? theme.textTheme.bodyMedium?.color?.withValues(
                                  alpha: 0.5,
                                )
                              : theme.textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (showIcon)
                      Icon(
                        Icons.calendar_month,
                        size: 16,
                        color: hasError
                            ? Colors.red
                            : theme.colorScheme.primary,
                      ),
                  ],
                ),
              ),
              if (hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 5, left: 12),
                  child: Text(
                    state.errorText!,
                    style: const TextStyle(color: Colors.red, fontSize: 11),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class HomeDropDownField extends StatelessWidget {
  final String hint;
  final List<String> items;
  final void Function(String?)? onChanged;
  final String? Function(String?)? validator;
  const HomeDropDownField({
    super.key,
    required this.hint,
    required this.items,
    this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FormField<String>(
      validator: validator,
      initialValue: null,
      builder: (FormFieldState<String> state) {
        final hasError = state.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasError ? Colors.red : theme.dividerColor,
                  width: hasError ? 1.5 : 1.0,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: theme.cardColor,
                  hint: Text(
                    hint,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.textTheme.bodyMedium?.color?.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                  items: items.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    state.didChange(val);
                    if (onChanged != null) onChanged!(val);
                  },
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 12),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
          ],
        );
      },
    );
  }
}

class HomeStatusPill extends StatelessWidget {
  final String text;
  final bool isSuccess;
  final Color? color;
  const HomeStatusPill({
    super.key,
    required this.text,
    required this.isSuccess,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color:
            color ??
            (isSuccess ? const Color(0xFF34A853) : const Color(0xFFE53935)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}

class HomeSortHeader extends StatelessWidget {
  final String label;
  final double? fontSize;
  final FontWeight? fontWeight;

  const HomeSortHeader({
    super.key,
    required this.label,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: fontWeight ?? FontWeight.bold,
            fontSize: fontSize ?? 12,
          ),
        ),
      ],
    );
  }
}

/// Opens a sleek modal bottom sheet for selecting a Cylinder Make with search
Future<CylinderData?> showCylinderMakeBottomSheet({
  required BuildContext context,
  required List<CylinderData> cylinderMakes,
  String? selectedId,
  String? selectedName,
}) {
  return showModalBottomSheet<CylinderData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return _CylinderMakeBottomSheet(
        cylinderMakes: cylinderMakes,
        selectedId: selectedId,
        selectedName: selectedName,
      );
    },
  );
}

class _CylinderMakeBottomSheet extends StatefulWidget {
  final List<CylinderData> cylinderMakes;
  final String? selectedId;
  final String? selectedName;

  const _CylinderMakeBottomSheet({
    required this.cylinderMakes,
    this.selectedId,
    this.selectedName,
  });

  @override
  State<_CylinderMakeBottomSheet> createState() =>
      _CylinderMakeBottomSheetState();
}

class _CylinderMakeBottomSheetState extends State<_CylinderMakeBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  late List<CylinderData> _filteredMakes;

  @override
  void initState() {
    super.initState();
    _filteredMakes = widget.cylinderMakes;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMakes = widget.cylinderMakes;
      } else {
        _filteredMakes = widget.cylinderMakes.where((item) {
          final fullname = (item.fullname ?? '').toLowerCase();
          final shortname = (item.shortname ?? '').toLowerCase();
          return fullname.contains(query) || shortname.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.78,
      ),
      margin: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // Draggable bar
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Select Cylinder Make",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${widget.cylinderMakes.length} makes available",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.8),
                    ),
                    tooltip: "Close",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor ??
                      theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.dividerColor.withValues(alpha: 0.7),
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search make by name or code...",
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: theme.textTheme.bodyMedium?.color
                          ?.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Divider(
              height: 1,
              color: theme.dividerColor.withValues(alpha: 0.5),
            ),

            // List of makes
            Flexible(
              child: _filteredMakes.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 40,
                        horizontal: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: theme.disabledColor,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No Cylinder Make Found",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Try searching with a different keyword",
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      itemCount: _filteredMakes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final item = _filteredMakes[index];
                        final isSelected = (widget.selectedId != null &&
                                item.id?.toString() == widget.selectedId) ||
                            (widget.selectedName != null &&
                                item.fullname?.trim().toLowerCase() ==
                                    widget.selectedName?.trim().toLowerCase());

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context, item);
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                        .withValues(alpha: 0.15)
                                    : theme.inputDecorationTheme.fillColor
                                        ?.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.dividerColor
                                          .withValues(alpha: 0.4),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.precision_manufacturing_rounded,
                                      size: 20,
                                      color: isSelected
                                          ? Colors.white
                                          : theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.fullname ?? "",
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? theme.colorScheme.primary
                                                : theme.textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                        if (item.shortname != null &&
                                            item.shortname!.trim().isNotEmpty &&
                                            item.shortname!.trim() !=
                                                item.fullname!.trim()) ...[
                                          const SizedBox(height: 3),
                                          Text(
                                            "Code: ${item.shortname}",
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: theme
                                                  .textTheme.bodyMedium?.color
                                                  ?.withValues(alpha: 0.65),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: theme.colorScheme.primary,
                                      size: 22,
                                    )
                                else
                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: theme.disabledColor
                                        .withValues(alpha: 0.7),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}
}

/// Form field widget that triggers the Cylinder Make bottom sheet
class HomeCylinderMakePickerField extends StatelessWidget {
  final String? selectedName;
  final VoidCallback onTap;
  final String? Function(String?)? validator;
  final bool enabled;

  const HomeCylinderMakePickerField({
    super.key,
    this.selectedName,
    required this.onTap,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelection = selectedName != null &&
        selectedName!.trim().isNotEmpty &&
        selectedName!.trim().toLowerCase() != "select";

    return FormField<String>(
      validator: validator,
      initialValue: hasSelection ? selectedName : null,
      builder: (state) {
        final hasError = state.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: enabled
                      ? theme.inputDecorationTheme.fillColor
                      : theme.disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: hasError ? Colors.red : theme.dividerColor,
                    width: hasError ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        hasSelection ? selectedName! : "Select Cylinder Make",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: hasSelection
                              ? (enabled
                                  ? theme.textTheme.bodyLarge?.color
                                  : theme.textTheme.bodyLarge?.color
                                      ?.withValues(alpha: 0.8))
                              : theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: enabled
                          ? theme.colorScheme.primary
                          : theme.disabledColor,
                    ),
                  ],
                ),
              ),
            ),
            if (hasError &&
                state.errorText != null &&
                state.errorText!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5, left: 12),
                child: Text(
                  state.errorText!,
                  style: const TextStyle(color: Colors.red, fontSize: 11),
                ),
              ),
          ],
        );
      },
    );
  }
}
