import 'package:flutter/material.dart';
import '../models/deprem.dart';

class DepremCard extends StatelessWidget {
  final Deprem deprem;

  const DepremCard({
    Key? key,
    required this.deprem,
  }) : super(key: key);

  // Büyüklüğe göre renk döndür
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

  // Büyüklüğe göre ikon döndür
  IconData _getBuyuklukIkonu(double buyukluk) {
    if (buyukluk >= 5.0) {
      return Icons.warning;
    } else if (buyukluk >= 4.0) {
      return Icons.error_outline;
    } else {
      return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyuklukRengi = _getBuyuklukRengi(deprem.buyukluk);
    final buyuklukIkonu = _getBuyuklukIkonu(deprem.buyukluk);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Üst satır: Büyüklük ve Kaynak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Büyüklük
                Row(
                  children: [
                    Icon(
                      buyuklukIkonu,
                      color: buyuklukRengi,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${deprem.buyukluk.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: buyuklukRengi,
                      ),
                    ),
                  ],
                ),
                // Kaynak badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: deprem.kaynak.toString().contains('kandilli')
                        ? Colors.blue.shade100
                        : Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    deprem.kaynak.toString().contains('kandilli')
                        ? 'Kandilli'
                        : 'AFAD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: deprem.kaynak.toString().contains('kandilli')
                          ? Colors.blue.shade700
                          : Colors.green.shade700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Lokasyon
            Row(
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    deprem.lokasyon,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Detaylar (Derinlik ve En Yakın Şehir)
            Row(
              children: [
                // Derinlik
                Row(
                  children: [
                    const Icon(Icons.vertical_align_bottom,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      '${deprem.derinlik.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                if (deprem.enYakinSehir != null) ...[
                  const SizedBox(width: 16),
                  // En yakın şehir
                  Row(
                    children: [
                      const Icon(Icons.location_city, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        deprem.enYakinSehir!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}


