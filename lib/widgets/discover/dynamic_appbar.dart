import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DynamicAppBar extends StatefulWidget implements PreferredSizeWidget {
  final double scrollOffset;
  final VoidCallback? onFilterPressed;
  final String title;
  final bool isMapInteracting;

  const DynamicAppBar({
    super.key,
    this.scrollOffset = 0.0,
    this.onFilterPressed,
    this.title = 'FoodBuddy',
    this.isMapInteracting = false,
  });

  @override
  State<DynamicAppBar> createState() => _DynamicAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _DynamicAppBarState extends State<DynamicAppBar>
    with TickerProviderStateMixin {

  late AnimationController _colorController;
  late AnimationController _elevationController;
  late Animation<Color?> _backgroundColorAnimation;
  late Animation<Color?> _textColorAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _elevationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _backgroundColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.white,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    _textColorAnimation = ColorTween(
      begin: Colors.white,
      end: Colors.black87,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));

    _elevationAnimation = Tween<double>(
      begin: 0.0,
      end: 4.0,
    ).animate(CurvedAnimation(
      parent: _elevationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(DynamicAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Trigger color animation based on scroll offset or map interaction
    final shouldBeOpaque = widget.scrollOffset > 50 || widget.isMapInteracting;

    if (shouldBeOpaque) {
      _colorController.forward();
      _elevationController.forward();
    } else {
      _colorController.reverse();
      _elevationController.reverse();
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    _elevationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_colorController, _elevationController]),
      builder: (context, child) {
        return AppBar(
          backgroundColor: _backgroundColorAnimation.value,
          elevation: _elevationAnimation.value,
          automaticallyImplyLeading: false,
          systemOverlayStyle: _getSystemOverlayStyle(),
          flexibleSpace: _buildFlexibleSpace(),
          title: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              color: _textColorAnimation.value,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
            child: Text(widget.title),
          ),
          centerTitle: false,
          actions: [
            _buildFilterButton(),
            const SizedBox(width: 16),
          ],
        );
      },
    );
  }

  Widget _buildFlexibleSpace() {
    return Container(
      decoration: BoxDecoration(
        gradient: widget.scrollOffset <= 50 && !widget.isMapInteracting
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              )
            : null,
      ),
    );
  }

  Widget _buildFilterButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 0),
      decoration: BoxDecoration(
        color: widget.scrollOffset <= 50 && !widget.isMapInteracting
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: widget.scrollOffset <= 50 && !widget.isMapInteracting
            ? Border.all(color: Colors.white.withValues(alpha: 0.3))
            : null,
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.filter_list_rounded,
            key: ValueKey(widget.scrollOffset > 50 || widget.isMapInteracting),
            color: widget.scrollOffset <= 50 && !widget.isMapInteracting
                ? Colors.white
                : Colors.grey.shade600,
            size: 22,
          ),
        ),
        onPressed: widget.onFilterPressed,
        tooltip: 'Filter restaurants',
      ),
    );
  }

  SystemUiOverlayStyle _getSystemOverlayStyle() {
    final isLight = widget.scrollOffset > 50 || widget.isMapInteracting;
    return isLight
        ? SystemUiOverlayStyle.dark
        : SystemUiOverlayStyle.light;
  }
}

// Additional gradient overlay widget for enhanced visual effects
class AppBarGradientOverlay extends StatelessWidget {
  final double opacity;
  final bool isVisible;

  const AppBarGradientOverlay({
    super.key,
    this.opacity = 0.7,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: MediaQuery.of(context).padding.top + kToolbarHeight + 20,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: opacity),
              Colors.black.withValues(alpha: opacity * 0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}

// Filter bottom sheet for the filter button
class FilterBottomSheet extends StatefulWidget {
  final List<String> selectedCuisines;
  final List<String> selectedPriceRanges;
  final Function(List<String>, List<String>) onFiltersApplied;

  const FilterBottomSheet({
    super.key,
    required this.selectedCuisines,
    required this.selectedPriceRanges,
    required this.onFiltersApplied,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late List<String> _selectedCuisines;
  late List<String> _selectedPriceRanges;

  final List<String> _cuisineOptions = [
    'Italian', 'Korean', 'Vegan', 'Desserts', 'American', 'Mexican',
    'Chinese', 'Japanese', 'Thai', 'Mediterranean', 'French'
  ];

  final List<String> _priceRangeOptions = ['₱', '₱₱', '₱₱₱', '₱₱₱₱'];

  @override
  void initState() {
    super.initState();
    _selectedCuisines = List.from(widget.selectedCuisines);
    _selectedPriceRanges = List.from(widget.selectedPriceRanges);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'Filter Restaurants',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ),

          // Cuisines section
          _buildSection(
            'Cuisine Type',
            _cuisineOptions,
            _selectedCuisines,
            (cuisine) {
              setState(() {
                if (_selectedCuisines.contains(cuisine)) {
                  _selectedCuisines.remove(cuisine);
                } else {
                  _selectedCuisines.add(cuisine);
                }
              });
            },
          ),

          // Price range section
          _buildSection(
            'Price Range',
            _priceRangeOptions,
            _selectedPriceRanges,
            (price) {
              setState(() {
                if (_selectedPriceRanges.contains(price)) {
                  _selectedPriceRanges.remove(price);
                } else {
                  _selectedPriceRanges.add(price);
                }
              });
            },
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Apply Filters${_getFilterCount() > 0 ? ' (${_getFilterCount()})' : ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String> options,
    List<String> selected,
    Function(String) onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selected.contains(option);
              return GestureDetector(
                onTap: () => onTap(option),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.black87 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.black87 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCuisines.clear();
      _selectedPriceRanges.clear();
    });
  }

  void _applyFilters() {
    widget.onFiltersApplied(_selectedCuisines, _selectedPriceRanges);
    Navigator.of(context).pop();
  }

  int _getFilterCount() {
    return _selectedCuisines.length + _selectedPriceRanges.length;
  }
}