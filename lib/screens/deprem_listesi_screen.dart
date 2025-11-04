import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/deprem_kaynagi.dart';
import '../providers/deprem_provider.dart';
import '../widgets/deprem_card.dart';

class DepremListesiScreen extends StatefulWidget {
  const DepremListesiScreen({Key? key}) : super(key: key);

  @override
  State<DepremListesiScreen> createState() => _DepremListesiScreenState();
}

class _DepremListesiScreenState extends State<DepremListesiScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Provider'ı başlat (ilk verileri yükle)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<DepremProvider>(context, listen: false);
      provider.initialize();
    });
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
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Son Depremler'),
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
          return RefreshIndicator(
            onRefresh: () => provider.refresh(),
            child: ListView.builder(
              itemCount: provider.depremler.length,
              itemBuilder: (context, index) {
                return DepremCard(deprem: provider.depremler[index]);
              },
            ),
          );
        },
      ),
    );
  }
}


