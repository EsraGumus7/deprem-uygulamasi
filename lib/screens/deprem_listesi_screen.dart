import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deprem_kaynagi.dart';
import '../models/siralama_tipi.dart';
import '../providers/deprem_provider.dart';
import '../widgets/deprem_card.dart';
import 'harita_screen.dart';
import 'ayarlar_screen.dart';

// Yavaş kaydırma için özel ScrollPhysics
class YavasScrollPhysics extends ClampingScrollPhysics {
  const YavasScrollPhysics({super.parent});

  @override
  YavasScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return YavasScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Kaydırma hızını yavaşlat (offset'i küçült)
    return super.applyPhysicsToUserOffset(position, offset * 0.15);
  }
}

class DepremListesiScreen extends StatefulWidget {
  const DepremListesiScreen({Key? key}) : super(key: key);

  @override
  State<DepremListesiScreen> createState() => _DepremListesiScreenState();
}

class _DepremListesiScreenState extends State<DepremListesiScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Lifecycle observer'ı ekle
    WidgetsBinding.instance.addObserver(this);
    
    // Provider'ı başlat (ilk verileri yükle)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DepremProvider>(context, listen: false);
      provider.initialize();
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Uygulama foreground'a geldiğinde otomatik refresh
      final provider = Provider.of<DepremProvider>(context, listen: false);
      provider.onAppResumed();
    }
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final provider = Provider.of<DepremProvider>(context, listen: false);
      final kaynak = _tabController.index == 0
          ? DepremKaynagi.kandilli
          : DepremKaynagi.afad;
      provider.changeKaynak(kaynak);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _siralamaDialogGoster(BuildContext context) {
    final provider = Provider.of<DepremProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _SiralamaBottomSheet(provider: provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabBarColor = Theme.of(context).colorScheme.primary;
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Son Depremler',
              style: TextStyle(
                color: tabBarColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HaritaScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.explore,
                    color: Colors.green,
                    size: 22,
                  ),
                  label: const Text(
                    'Harita',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                // Sıralama ve Filtreleme butonu
                Consumer<DepremProvider>(
                  builder: (context, provider, _) {
                    final aktifFiltreVar = provider.minBuyukluk != null;
                    return Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.sort),
                          tooltip: 'Sırala ve Filtrele',
                          onPressed: () => _siralamaDialogGoster(context),
                        ),
                        if (aktifFiltreVar)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                // Ayarlar butonu (bildirim ikonu ile)
                IconButton(
                  icon: const Icon(Icons.notifications),
                  tooltip: 'Bildirim Ayarları',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AyarlarScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Kandilli'),
            Tab(text: 'AFAD'),
          ],
        ),
      ),
      body: Consumer<DepremProvider>(
        builder: (context, provider, child) {
          // Loading durumu
          if (provider.isLoading && provider.depremler.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error durumu
          if (provider.error != null && provider.depremler.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Hata: ${provider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refresh(),
                    child: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            );
          }

          // Liste boş durumu
          if (provider.depremler.isEmpty) {
            return const Center(
              child: Text('Henüz deprem verisi yok'),
            );
          }

          // Deprem listesi
          final filtrelenmisListe = provider.depremler;
          
          if (filtrelenmisListe.isEmpty && !provider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.filter_alt_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Filtreleme sonucu bulunamadı',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.setMinBuyukluk(null);
                    },
                    child: const Text('Filtreyi Temizle'),
                  ),
                ],
              ),
            );
          }

          // Yeni deprem bildirimi göster
          if (provider.yeniDepremSayisi > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${provider.yeniDepremSayisi} yeni deprem eklendi',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          provider.yeniDepremSayisiniSifirla();
                        },
                        child: const Text('KAPAT', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'Tamam',
                    textColor: Colors.white,
                    onPressed: () {
                      provider.yeniDepremSayisiniSifirla();
                    },
                  ),
                ),
              );
            });
          }

          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              key: ValueKey('deprem_list_${filtrelenmisListe.length}'), // Yeni depremler geldiğinde rebuild et
              physics: const YavasScrollPhysics(),
              itemCount: filtrelenmisListe.length,
              itemBuilder: (context, index) {
                return DepremCard(deprem: filtrelenmisListe[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

// Sıralama ve Filtreleme Bottom Sheet
class _SiralamaBottomSheet extends StatefulWidget {
  final DepremProvider provider;

  const _SiralamaBottomSheet({required this.provider});

  @override
  State<_SiralamaBottomSheet> createState() => _SiralamaBottomSheetState();
}

class _SiralamaBottomSheetState extends State<_SiralamaBottomSheet> {
  late double _minBuyukluk;

  @override
  void initState() {
    super.initState();
    _minBuyukluk = widget.provider.minBuyukluk ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık ve Sıfırla
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sırala ve Filtrele',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      widget.provider.setSiralamaTipi(null);
                      widget.provider.setMinBuyukluk(null);
                      Navigator.pop(context);
                    },
                    child: const Text('Sıfırla'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Büyüklük Filtresi
              const Text(
                'Minimum Büyüklük',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_minBuyukluk.toStringAsFixed(1)} ve üzeri',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Slider(
                value: _minBuyukluk,
                min: 0.0,
                max: 8.0,
                divisions: 80,
                label: _minBuyukluk.toStringAsFixed(1),
                onChanged: (value) {
                  setState(() {
                    _minBuyukluk = value;
                  });
                  // Canlı güncelleme
                  widget.provider.setMinBuyukluk(value > 0 ? value : null);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _minBuyukluk = 0.0;
                      });
                      widget.provider.setMinBuyukluk(null);
                    },
                    child: const Text('Kaldır'),
                  ),
                ],
              ),
              
              const Divider(),
              const SizedBox(height: 16),
              
              // Sıralama Seçenekleri
              const Text(
                'Sıralama',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              
              _buildSiralamaSecenek(
                context,
                'Büyüklük (Büyükten Küçüğe)',
                SiralamaTipi.buyuklukAzalan,
                Icons.arrow_downward,
              ),
              _buildSiralamaSecenek(
                context,
                'Büyüklük (Küçükten Büyüğe)',
                SiralamaTipi.buyuklukArtan,
                Icons.arrow_upward,
              ),
              _buildSiralamaSecenek(
                context,
                'Tarih (En Yeni)',
                SiralamaTipi.tarihYeni,
                Icons.access_time,
              ),
              _buildSiralamaSecenek(
                context,
                'Tarih (En Eski)',
                SiralamaTipi.tarihEski,
                Icons.history,
              ),
              _buildSiralamaSecenek(
                context,
                'Derinlik (Derinden Sığa)',
                SiralamaTipi.derinlikAzalan,
                Icons.vertical_align_bottom,
              ),
              _buildSiralamaSecenek(
                context,
                'Derinlik (Sığdan Derine)',
                SiralamaTipi.derinlikArtan,
                Icons.vertical_align_top,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSiralamaSecenek(
    BuildContext context,
    String baslik,
    SiralamaTipi tip,
    IconData ikon,
  ) {
    return Consumer<DepremProvider>(
      builder: (context, provider, child) {
        final secili = provider.siralamaTipi == tip;
        return ListTile(
          leading: Icon(ikon, color: secili ? Colors.blue : Colors.grey),
          title: Text(baslik),
          trailing: secili ? const Icon(Icons.check, color: Colors.blue) : null,
          onTap: () {
            provider.setSiralamaTipi(secili ? null : tip);
          },
        );
      },
    );
  }
}


