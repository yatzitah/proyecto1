import 'package:flutter/material.dart';

void main() {
  runApp(const LuxuryGalleryApp());
}

class LuxuryGalleryApp extends StatelessWidget {
  const LuxuryGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Galería de Lujo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09080C),
        primaryColor: const Color(0xFFD4AF37),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF131118),
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFE6C567),
        ),
      ),
      home: const GalleryScreen(),
    );
  }
}

// Clase para representar un trazo en el lienzo
class DrawingPoint {
  Offset? point;
  Color color;
  double strokeWidth;
  bool isEraser;

  DrawingPoint({
    required this.point,
    required this.color,
    required this.strokeWidth,
    this.isEraser = false,
  });
}

class GalleryItem {
  final int id;
  final String title;
  final String category;
  final String assetPath;
  bool isFavorite;
  bool isDeleted;
  double brightness;
  double aspectRatio;
  BoxFit boxFit;
  bool isDrawingMode;
  bool isEraserMode;
  List<DrawingPoint> points; // Almacena los trazos hechos a mano en cada imagen

  GalleryItem({
    required this.id,
    required this.title,
    required this.category,
    required this.assetPath,
    this.isFavorite = false,
    this.isDeleted = false,
    this.brightness = 1.0,
    this.aspectRatio = 1.0,
    this.boxFit = BoxFit.contain,
    this.isDrawingMode = false,
    this.isEraserMode = false,
    List<DrawingPoint>? points,
  }) : points = points ?? [];
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  final List<GalleryItem> _items = List.generate(30, (index) {
    String category;
    String title;
    String fileName;

    if (index < 10) {
      category = "BTS (Jungkook & Taehyung)";
      title = index % 2 == 0
          ? "Jungkook - Royal #${index + 1}"
          : "Taehyung - Elegant #${index + 1}";
      fileName = "bts${index + 1}.jpg";
    } else if (index < 20) {
      category = "Demon Slayer";
      title = index % 2 == 0
          ? "Tokito Muichiro #${index - 9}"
          : "Agatsuma Zenitsu #${index - 9}";
      int num = index - 9;
      fileName = (num == 1 || num == 7) ? "demon$num.png" : "demon$num.jpg";
    } else {
      category = "Yu-Gi-Oh!";
      title = index % 2 == 0
          ? "Yugi Mutou #${index - 19}"
          : "El Faraón Atem #${index - 19}";
      int num = index - 19;
      fileName = (num == 6) ? "yugi$num.png" : "yugi$num.jpg";
    }

    return GalleryItem(
      id: index,
      title: title,
      category: category,
      assetPath: 'assets/$fileName',
    );
  });

  int _currentIndex = 0;
  bool _showFavoritesOnly = false;
  bool _showTrashOnly = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  List<GalleryItem> get _currentList {
    if (_showTrashOnly) {
      return _items.where((item) => item.isDeleted).toList();
    } else if (_showFavoritesOnly) {
      return _items
          .where((item) => item.isFavorite && !item.isDeleted)
          .toList();
    } else {
      return _items.where((item) => !item.isDeleted).toList();
    }
  }

  int getSafeIndex() {
    if (_currentList.isEmpty) return 0;
    if (_currentIndex >= _currentList.length) return 0;
    return _currentIndex;
  }

  void _animateChange(VoidCallback action) {
    _fadeController.reverse().then((_) {
      setState(action);
      _fadeController.forward();
    });
  }

  void _nextImage() {
    if (_currentList.isNotEmpty) {
      _animateChange(() {
        _currentIndex = (_currentIndex + 1) % _currentList.length;
      });
    }
  }

  void _prevImage() {
    if (_currentList.isNotEmpty) {
      _animateChange(() {
        _currentIndex =
            (_currentIndex - 1 + _currentList.length) % _currentList.length;
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      if (_currentList.isNotEmpty) {
        final item = _currentList[getSafeIndex()];
        item.isFavorite = !item.isFavorite;
      }
    });
  }

  void _moveToTrash() {
    setState(() {
      if (_currentList.isNotEmpty) {
        final item = _currentList[getSafeIndex()];
        item.isDeleted = true;
        if (_currentIndex >= _currentList.length && _currentIndex > 0) {
          _currentIndex--;
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Movido a la Papelera 🗑️',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFD4AF37),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _restoreItem(GalleryItem item) {
    setState(() {
      item.isDeleted = false;
      _currentIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Imagen restaurada a la galería ✨',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: const Color(0xFFD4AF37),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _deletePermanent(GalleryItem item) {
    setState(() {
      _items.removeWhere((element) => element.id == item.id);
      if (_currentIndex >= _currentList.length && _currentIndex > 0) {
        _currentIndex--;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Eliminado permanentemente ❌',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _openEditor(GalleryItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF16141F),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '✨ Estudio Royal: Edición y Pintura',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF2A2638)),
                  const SizedBox(height: 6),
                  const Text(
                    'Ajuste de Brillo',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.brightness_low,
                        color: Color(0xFFD4AF37),
                        size: 16,
                      ),
                      Expanded(
                        child: Slider(
                          value: item.brightness,
                          min: 0.4,
                          max: 1.6,
                          activeColor: const Color(0xFFD4AF37),
                          inactiveColor: Colors.white24,
                          onChanged: (value) {
                            setModalState(() => item.brightness = value);
                            setState(() {});
                          },
                        ),
                      ),
                      const Icon(
                        Icons.brightness_high,
                        color: Color(0xFFD4AF37),
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Modo de Visualización (Evitar cortes)',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _fitOptionButton(
                        'Completa (Contain)',
                        BoxFit.contain,
                        item.boxFit,
                        (fit) {
                          setModalState(() => item.boxFit = fit);
                          setState(() {});
                        },
                      ),
                      _fitOptionButton(
                        'Rellenar (Cover)',
                        BoxFit.cover,
                        item.boxFit,
                        (fit) {
                          setModalState(() => item.boxFit = fit);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Recorte Personalizado',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _cropOptionButton('Libre', 0.8, item.aspectRatio, (val) {
                        setModalState(() => item.aspectRatio = val);
                        setState(() {});
                      }),
                      _cropOptionButton(
                        'Cuadrado (1:1)',
                        1.0,
                        item.aspectRatio,
                        (val) {
                          setModalState(() => item.aspectRatio = val);
                          setState(() {});
                        },
                      ),
                      _cropOptionButton(
                        'Vertical (9:16)',
                        0.56,
                        item.aspectRatio,
                        (val) {
                          setModalState(() => item.aspectRatio = val);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Herramientas de Dibujo y Borrador',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _drawingOptionButton(
                        'Pincel',
                        Icons.brush,
                        item.isDrawingMode && !item.isEraserMode,
                        () {
                          setModalState(() {
                            item.isDrawingMode = true;
                            item.isEraserMode = false;
                          });
                          setState(() {});
                        },
                      ),
                      _drawingOptionButton(
                        'Borrador',
                        Icons.cleaning_services,
                        item.isDrawingMode && item.isEraserMode,
                        () {
                          setModalState(() {
                            item.isDrawingMode = true;
                            item.isEraserMode = true;
                          });
                          setState(() {});
                        },
                      ),
                      _drawingOptionButton(
                        'Limpiar Todo',
                        Icons.delete_sweep,
                        false,
                        () {
                          setModalState(() {
                            item.points.clear();
                            item.isDrawingMode = false;
                            item.isEraserMode = false;
                          });
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Guardar y Salir',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _fitOptionButton(
    String label,
    BoxFit fit,
    BoxFit currentFit,
    Function(BoxFit) onTap,
  ) {
    bool isSelected = currentFit == fit;
    return InkWell(
      onTap: () => onTap(fit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withOpacity(0.2)
              : const Color(0xFF201D29),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _cropOptionButton(
    String label,
    double ratio,
    double currentRatio,
    Function(double) onTap,
  ) {
    bool isSelected = currentRatio == ratio;
    return InkWell(
      onTap: () => onTap(ratio),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withOpacity(0.2)
              : const Color(0xFF201D29),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _drawingOptionButton(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withOpacity(0.3)
              : const Color(0xFF201D29),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFD4AF37) : Colors.white60,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeList = _currentList;

    String appBarTitle = '👑 Galería Legendaria 👑';
    if (_showTrashOnly) {
      appBarTitle = '🗑️ Papelera 🗑️';
    } else if (_showFavoritesOnly) {
      appBarTitle = '✨ Favoritos ✨';
    }

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.diamond, color: Color(0xFFD4AF37), size: 18),
              const SizedBox(width: 6),
              Text(
                appBarTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFFD4AF37),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _showTrashOnly ? Icons.collections : Icons.delete_outline,
              color: _showTrashOnly
                  ? Colors.redAccent
                  : const Color(0xFFD4AF37),
            ),
            tooltip: 'Ver Papelera',
            onPressed: () {
              setState(() {
                _showTrashOnly = !_showTrashOnly;
                _showFavoritesOnly = false;
                _currentIndex = 0;
              });
            },
          ),
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.collections : Icons.favorite,
              color: const Color(0xFFD4AF37),
            ),
            tooltip: 'Ver Favoritos',
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
                _showTrashOnly = false;
                _currentIndex = 0;
              });
            },
          ),
        ],
      ),
      body: activeList.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 60,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _showTrashOnly
                        ? 'La papelera está vacía.'
                        : (_showFavoritesOnly
                              ? 'No hay favoritos guardados.'
                              : 'La galería está vacía.'),
                    style: const TextStyle(color: Colors.white54, fontSize: 15),
                  ),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final currentItem = activeList[getSafeIndex()];

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: constraints.maxWidth * 0.92,
                          height: constraints.maxHeight * 0.88,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B1824), Color(0xFF100E14)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.4),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.6),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFD4AF37)
                                            .withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: const Color(0xFFD4AF37)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        currentItem.category,
                                        style: const TextStyle(
                                          color: Color(0xFFD4AF37),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        if (currentItem.isDrawingMode)
                                          Container(
                                            margin: const EdgeInsets.only(
                                              right: 8,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: currentItem.isEraserMode
                                                  ? Colors.redAccent
                                                        .withOpacity(0.2)
                                                  : Colors.greenAccent
                                                        .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              currentItem.isEraserMode
                                                  ? '🧹 Borrador Activo'
                                                  : '🖌️ Pintando',
                                              style: TextStyle(
                                                color: currentItem.isEraserMode
                                                    ? Colors.redAccent
                                                    : Colors.greenAccent,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          '${getSafeIndex() + 1} / ${activeList.length}',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                  ),
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: currentItem.aspectRatio,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(18),
                                        child: GestureDetector(
                                          onPanUpdate: currentItem.isDrawingMode
                                              ? (details) {
                                                  setState(() {
                                                    RenderBox renderBox =
                                                        context.findRenderObject()
                                                            as RenderBox;
                                                    Offset localPosition =
                                                        details.localPosition;

                                                    if (currentItem
                                                        .isEraserMode) {
                                                      // Borra puntos cercanos al dedo
                                                      currentItem.points.removeWhere((
                                                        element,
                                                      ) {
                                                        if (element.point ==
                                                            null)
                                                          return false;
                                                        return (element.point! -
                                                                    localPosition)
                                                                .distance <
                                                            25;
                                                      });
                                                    } else {
                                                      // Dibuja un nuevo punto dorado
                                                      currentItem.points.add(
                                                        DrawingPoint(
                                                          point: localPosition,
                                                          color: const Color(
                                                            0xFFD4AF37,
                                                          ),
                                                          strokeWidth: 4.0,
                                                        ),
                                                      );
                                                    }
                                                  });
                                                }
                                              : null,
                                          onPanEnd: currentItem.isDrawingMode
                                              ? (details) {
                                                  setState(() {
                                                    currentItem.points.add(
                                                      DrawingPoint(
                                                        point: null,
                                                        color:
                                                            Colors.transparent,
                                                        strokeWidth: 0,
                                                      ),
                                                    );
                                                  });
                                                }
                                              : null,
                                          child: Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ColorFiltered(
                                                colorFilter: ColorFilter.matrix(
                                                  [
                                                    currentItem.brightness,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    currentItem.brightness,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    currentItem.brightness,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    1,
                                                    0,
                                                  ],
                                                ),
                                                child: Image.asset(
                                                  currentItem.assetPath,
                                                  fit: currentItem.boxFit,
                                                  width: double.infinity,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: const Color(
                                                        0xFF221F2B,
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          const Icon(
                                                            Icons
                                                                .image_not_supported_outlined,
                                                            color: Color(
                                                              0xFFD4AF37,
                                                            ),
                                                            size: 35,
                                                          ),
                                                          const SizedBox(
                                                            height: 6,
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  6.0,
                                                                ),
                                                            child: Text(
                                                              'No se encontró:\n${currentItem.assetPath}',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .white70,
                                                                    fontSize:
                                                                        10,
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              CustomPaint(
                                                painter: GalleryPainter(
                                                  points: currentItem.points,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                child: Text(
                                  currentItem.title,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF14121A),
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(28),
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                      color: const Color(0xFFD4AF37)
                                          .withOpacity(0.15),
                                    ),
                                  ),
                                ),
                                child: _showTrashOnly
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildRoyalButton(
                                            icon: Icons.restore,
                                            label: 'Restaurar',
                                            color: Colors.greenAccent,
                                            onTap: () =>
                                                _restoreItem(currentItem),
                                          ),
                                          _buildRoyalButton(
                                            icon: Icons.delete_forever,
                                            label: 'Eliminar Permanente',
                                            color: Colors.redAccent,
                                            onTap: () =>
                                                _deletePermanent(currentItem),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildRoyalButton(
                                            icon: Icons.tune_rounded,
                                            label: 'Ajustes',
                                            onTap: () =>
                                                _openEditor(currentItem),
                                          ),
                                          _buildRoyalButton(
                                            icon: currentItem.isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border_rounded,
                                            label: 'Favoritos',
                                            color: currentItem.isFavorite
                                                ? Colors.redAccent
                                                : Colors.white,
                                            onTap: _toggleFavorite,
                                          ),
                                          _buildRoyalButton(
                                            icon: Icons.delete_sweep_rounded,
                                            label: 'Eliminar',
                                            color: Colors.red.shade300,
                                            onTap: _moveToTrash,
                                          ),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 2,
                      child: InkWell(
                        onTap: _prevImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1824).withOpacity(0.9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFFD4AF37),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      child: InkWell(
                        onTap: _nextImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1824).withOpacity(0.9),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFD4AF37).withOpacity(0.3),
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFFD4AF37),
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildRoyalButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Pintor personalizado para renderizar los trazos sobre la imagen
class GalleryPainter extends CustomPainter {
  final List<DrawingPoint> points;

  GalleryPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].point != null && points[i + 1].point != null) {
        paint.color = points[i].color;
        paint.strokeWidth = points[i].strokeWidth;
        canvas.drawLine(points[i].point!, points[i + 1].point!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
