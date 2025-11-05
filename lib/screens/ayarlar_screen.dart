import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/bildirim_service.dart';
import '../providers/deprem_provider.dart';

class AyarlarScreen extends StatefulWidget {
  const AyarlarScreen({Key? key}) : super(key: key);

  @override
  State<AyarlarScreen> createState() => _AyarlarScreenState();
}

class _AyarlarScreenState extends State<AyarlarScreen> {
  bool _bildirimAktif = true;
  double _bildirimEsik = 4.0;
  int _kontrolAraligi = 2;

  @override
  void initState() {
    super.initState();
    _yukleAyarlar();
  }

  Future<void> _yukleAyarlar() async {
    final aktif = await BildirimService.isBildirimAktif();
    final esik = await BildirimService.getBildirimEsik();
    final aralik = await BildirimService.getKontrolAraligi();
    setState(() {
      _bildirimAktif = aktif;
      _bildirimEsik = esik;
      _kontrolAraligi = aralik;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bildirimler Bölümü
          const Text(
            'Bildirimler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Bildirim Açık/Kapalı
          SwitchListTile(
            title: const Text('Bildirimleri Etkinleştir'),
            subtitle: const Text('Yüksek büyüklükteki depremler için bildirim al'),
            value: _bildirimAktif,
            onChanged: (value) async {
              setState(() {
                _bildirimAktif = value;
              });
              await BildirimService.setBildirimAktif(value);
              
              if (value) {
                await BildirimService.requestPermission();
              }
            },
          ),
          
          const Divider(),
          const SizedBox(height: 16),
          
          // Bildirim Eşiği
          const Text(
            'Bildirim Eşiği',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_bildirimEsik.toStringAsFixed(1)} ve üzeri büyüklükteki depremler için bildirim al',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Slider(
            value: _bildirimEsik,
            min: 3.0,
            max: 7.0,
            divisions: 40,
            label: _bildirimEsik.toStringAsFixed(1),
            onChanged: (value) async {
              setState(() {
                _bildirimEsik = value;
              });
              await BildirimService.setBildirimEsik(value);
            },
          ),
          const SizedBox(height: 24),
          
          const Divider(),
          const SizedBox(height: 16),
          
          // Kontrol Aralığı
          const Text(
            'Kontrol Aralığı',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _kontrolAraligi == 1 
                ? 'Her $_kontrolAraligi dakikada bir kontrol et (Hızlı - Pil tüketimi yüksek)'
                : 'Her $_kontrolAraligi dakikada bir kontrol et',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Slider(
            value: _kontrolAraligi.toDouble(),
            min: 1.0,
            max: 10.0,
            divisions: 9,
            label: '$_kontrolAraligi dakika',
            onChanged: (value) async {
              final yeniAralik = value.toInt();
              setState(() {
                _kontrolAraligi = yeniAralik;
              });
              await BildirimService.setKontrolAraligi(yeniAralik);
              
              // Provider'da periyodik kontrolü yenile
              final provider = Provider.of<DepremProvider>(context, listen: false);
              await provider.periyodikKontroluYenile();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Kontrol aralığı ${yeniAralik} dakikaya ayarlandı'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

