import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/api/quran_preferences_service.dart';
import '../../data/model/quran_surah_model.dart';

class QuranReadingScreen extends StatefulWidget {
  final List<QuranSurahModel> surahs;
  final int initialIndex;
  final int? initialAyah;

  const QuranReadingScreen({
    super.key,
    required this.surahs,
    required this.initialIndex,
    this.initialAyah,
  });

  @override
  State<QuranReadingScreen> createState() => _QuranReadingScreenState();
}

class _QuranReadingScreenState extends State<QuranReadingScreen> {
  final QuranPreferencesService _preferencesService = QuranPreferencesService();

  final ScrollController _scrollController = ScrollController();

  final GlobalKey _quranTextKey = GlobalKey();
  late List<GlobalKey> _ayahKeys;

  double fontSize = 25;
  int currentAyah = 1;
  bool isBookmarked = false;
  bool _isTrackingScroll = false;

  @override
  void initState() {
    super.initState();

    final surah = widget.surahs[widget.initialIndex];

    currentAyah =
        widget.initialAyah != null &&
            widget.initialAyah! >= 1 &&
            widget.initialAyah! <= surah.ayahCount
        ? widget.initialAyah!
        : 1;

    _ayahKeys = List.generate(surah.ayahCount, (_) => GlobalKey());

    _scrollController.addListener(_updateCurrentAyahFromScroll);

    _savePosition();
    _checkBookmark();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreInitialAyah();
    });
  }

  Future<void> _restoreInitialAyah() async {
    if (!mounted) return;

    final ayahContext = _ayahKeys[currentAyah - 1].currentContext;

    if (ayahContext != null) {
      await Scrollable.ensureVisible(
        ayahContext,
        alignment: 0.25,
        duration: Duration.zero,
      );
    }

    if (!mounted) return;

    _isTrackingScroll = true;
    _updateCurrentAyahFromScroll();
  }

  void _updateCurrentAyahFromScroll() {
    if (!_isTrackingScroll || !_scrollController.hasClients || !mounted) {
      return;
    }

    final quranContext = _quranTextKey.currentContext;

    if (quranContext == null) return;

    final quranObject = quranContext.findRenderObject();

    if (quranObject is! RenderBox || !quranObject.hasSize) return;

    final quranTop = quranObject.localToGlobal(Offset.zero).dy;
    final quranBottom = quranTop + quranObject.size.height;

    int? visibleAyah;

    for (var index = 0; index < _ayahKeys.length; index++) {
      final ayahContext = _ayahKeys[index].currentContext;

      if (ayahContext == null) continue;

      final ayahObject = ayahContext.findRenderObject();

      if (ayahObject is! RenderBox || !ayahObject.hasSize) continue;

      final ayahTop = ayahObject.localToGlobal(Offset.zero).dy;
      final ayahBottom = ayahTop + ayahObject.size.height;

      if (ayahBottom > quranTop + 8 && ayahTop < quranBottom) {
        visibleAyah = index + 1;
        break;
      }
    }

    if (visibleAyah == null || visibleAyah == currentAyah) return;

    setState(() {
      currentAyah = visibleAyah!;
    });

    _savePosition();
  }

  Future<void> _savePosition() async {
    await _preferencesService.saveLastPosition(
      surahNumber: widget.surahs[widget.initialIndex].number,
      ayahNumber: currentAyah,
    );
  }

  Future<void> _checkBookmark() async {
    final result = await _preferencesService.isBookmarked(
      surahNumber: widget.surahs[widget.initialIndex].number,
      ayahNumber: currentAyah,
    );

    if (!mounted) return;

    setState(() {
      isBookmarked = result;
    });
  }

  Future<void> _toggleBookmark() async {
    final surahNumber = widget.surahs[widget.initialIndex].number;

    if (isBookmarked) {
      await _preferencesService.removeBookmark(
        surahNumber: surahNumber,
        ayahNumber: currentAyah,
      );
    } else {
      await _preferencesService.addBookmark(
        surahNumber: surahNumber,
        ayahNumber: currentAyah,
      );
    }

    if (!mounted) return;

    setState(() {
      isBookmarked = !isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isBookmarked
              ? 'تم حفظ الآية في الآيات المحفوظة'
              : 'تم حذف الآية من الآيات المحفوظة',
        ),
      ),
    );
  }

  String _toArabicNumbers(int number) {
    const numbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    return number
        .toString()
        .split('')
        .map((digit) => numbers[int.parse(digit)])
        .join();
  }

  String _getSelectedAyahText() {
    final surah = widget.surahs[widget.initialIndex];

    final ayah = surah.ayahs.firstWhere((ayah) => ayah.number == currentAyah);

    return 'سورة ${surah.name} - الآية ${_toArabicNumbers(currentAyah)}\n\n'
        '${ayah.text}\n\n'
        'المصدر: Tanzil Project - https://tanzil.net';
  }

  Future<void> _copyAyah() async {
    await Clipboard.setData(ClipboardData(text: _getSelectedAyahText()));

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('تم نسخ الآية بنجاح')));
  }

  Future<void> _shareAyah() async {
    await SharePlus.instance.share(ShareParams(text: _getSelectedAyahText()));
  }

  void _navigateToSurah(int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            QuranReadingScreen(surahs: widget.surahs, initialIndex: index),
      ),
    );
  }

  void _increaseFont() {
    if (fontSize < 40) {
      setState(() {
        fontSize += 2;
      });
    }
  }

  void _decreaseFont() {
    if (fontSize > 18) {
      setState(() {
        fontSize -= 2;
      });
    }
  }

  Future<void> _selectAyah() async {
    final controller = TextEditingController(text: currentAyah.toString());

    final selected = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('الانتقال إلى آية'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'اكتب رقم الآية',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);

                if (value == null ||
                    value < 1 ||
                    value > widget.surahs[widget.initialIndex].ayahCount) {
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: const Text('انتقال'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (selected == null || !mounted) return;

    setState(() {
      currentAyah = selected;
    });

    await _savePosition();
    await _checkBookmark();

    if (!mounted) return;

    await _scrollToAyah(selected);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('أنت الآن عند الآية رقم ${_toArabicNumbers(selected)}'),
      ),
    );
  }

  Future<void> _scrollToAyah(int ayahNumber) async {
    final ayahContext = _ayahKeys[ayahNumber - 1].currentContext;

    if (ayahContext == null) return;

    await Scrollable.ensureVisible(
      ayahContext,
      alignment: 0.25,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateCurrentAyahFromScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surah = widget.surahs[widget.initialIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سورة ${surah.name}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.menu_book_rounded,
                  size: 38,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 10),
                Text(
                  'سورة ${surah.name}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text('عدد الآيات: ${surah.ayahCount}'),
                const SizedBox(height: 6),
                Text(
                  'الآية المحددة: ${_toArabicNumbers(currentAyah)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  const Text(
                    'حجم الخط',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        onPressed: _decreaseFont,
                        icon: const Icon(Icons.remove),
                        tooltip: 'تصغير الخط',
                      ),
                      const SizedBox(width: 20),
                      Text(
                        fontSize.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton.filledTonal(
                        onPressed: _increaseFont,
                        icon: const Icon(Icons.add),
                        tooltip: 'تكبير الخط',
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            fontSize = 25;
                          });
                        },
                        icon: const Icon(Icons.restart_alt),
                        tooltip: 'الحجم الافتراضي',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _selectAyah,
              icon: const Icon(Icons.pin_drop_outlined),
              label: const Text(
                'الانتقال إلى آية معينة',
                style: TextStyle(fontSize: 16),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleBookmark,
              icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
              label: Text(
                isBookmarked ? 'إزالة من الآيات المحفوظة' : 'احفظ هذه الآية',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _copyAyah,
              icon: const Icon(Icons.copy),
              label: const Text('نسخ الآية', style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _shareAyah,
              icon: const Icon(Icons.share),
              label: const Text('مشاركة الآية', style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            key: _quranTextKey,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: theme.dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final ayah in surah.ayahs)
                    Padding(
                      key: _ayahKeys[ayah.number - 1],
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Text(
                        '${ayah.text} ۝${_toArabicNumbers(ayah.number)}',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                          color: ayah.number == currentAyah
                              ? theme.colorScheme.tertiary
                              : theme.colorScheme.primary,
                          fontSize: fontSize,
                          height: 2.2,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.initialIndex > 0
                      ? () => _navigateToSurah(widget.initialIndex - 1)
                      : null,
                  child: const Text('السورة السابقة'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.initialIndex < widget.surahs.length - 1
                      ? () => _navigateToSurah(widget.initialIndex + 1)
                      : null,
                  child: const Text('السورة التالية'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
