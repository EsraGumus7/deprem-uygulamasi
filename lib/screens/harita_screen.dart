import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/deprem.dart';
import '../providers/deprem_provider.dart';

class HaritaScreen extends StatelessWidget {
  const HaritaScreen({Key? key}) : super(key: key);

  Color _getBuyuklukRengi(double buyukluk) {
    if (buyukluk >= 5.0) {
      return Colors.red;
    } else if (buyukluk >= 4.0) {
      return Colors.orange;
    } else if (buyukluk >= 3.0) {
      return Colors.yellow.shade700;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deprem Haritası'),
      ),
      body: Consumer<DepremProvider>(
        builder: (context, provider, child) {
          final depremler = provider.depremler;
          
          // Koordinatı olan depremleri filtrele
          final koordinatliDepremler = depremler
              .where((d) => d.enlem != null && d.boylam != null)
              .toList();

          if (koordinatliDepremler.isEmpty) {
            return const Center(
              child: Text('Haritada gösterilecek deprem bulunamadı'),
            );
          }

          // Tüm depremlerin merkez noktasını hesapla
          double? toplamEnlem = 0;
          double? toplamBoylam = 0;
          int sayac = 0;
          
          for (var deprem in koordinatliDepremler) {
            if (deprem.enlem != null && deprem.boylam != null) {
              toplamEnlem = (toplamEnlem ?? 0) + deprem.enlem!;
              toplamBoylam = (toplamBoylam ?? 0) + deprem.boylam!;
              sayac++;
            }
          }
          
          final merkezNokta = sayac > 0
              ? LatLng(toplamEnlem! / sayac, toplamBoylam! / sayac)
              : LatLng(39.0, 35.0); // Türkiye'nin merkezi

          return FlutterMap(
            options: MapOptions(
              initialCenter: merkezNokta,
              initialZoom: 6.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.deprem_projesi',
              ),
              MarkerLayer(
                markers: koordinatliDepremler.map((deprem) {
                  return Marker(
                    point: LatLng(deprem.enlem!, deprem.boylam!),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        _showDepremBilgisi(context, deprem);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: _getBuyuklukRengi(deprem.buyukluk),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            deprem.buyukluk.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDepremBilgisi(BuildContext context, Deprem deprem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${deprem.buyukluk.toStringAsFixed(1)} - ${deprem.lokasyon}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Büyüklük: ${deprem.buyukluk.toStringAsFixed(1)}'),
            Text('Derinlik: ${deprem.derinlik.toStringAsFixed(1)} km'),
            if (deprem.enYakinSehir != null)
              Text('En Yakın Şehir: ${deprem.enYakinSehir}'),
            if (deprem.tarih != null)
              Text('Tarih: ${deprem.tarih!.day}.${deprem.tarih!.month}.${deprem.tarih!.year} ${deprem.tarih!.hour}:${deprem.tarih!.minute.toString().padLeft(2, '0')}'),
            Text('Kaynak: ${deprem.kaynak.toString().contains('kandilli') ? 'Kandilli' : 'AFAD'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}

