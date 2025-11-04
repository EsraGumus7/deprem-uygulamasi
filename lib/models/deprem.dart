import 'deprem_kaynagi.dart';

class Deprem {
  final String earthquakeId;
  final DepremKaynagi kaynak;
  final String lokasyon;
  final double buyukluk;
  final double derinlik;
  final double? enlem;
  final double? boylam;
  final String? enYakinSehir;

  Deprem({
    required this.earthquakeId,
    required this.kaynak,
    required this.lokasyon,
    required this.buyukluk,
    required this.derinlik,
    this.enlem,
    this.boylam,
    this.enYakinSehir,
  });

  // JSON'dan Deprem objesi oluşturma (Kandilli ve AFAD formatlarını destekler)
  factory Deprem.fromJson(Map<String, dynamic> json) {
    // Kaynağı belirle
    final provider = json['provider']?.toString().toLowerCase() ?? '';
    final kaynak = provider.contains('kandilli')
        ? DepremKaynagi.kandilli
        : DepremKaynagi.afad;

    // Büyüklük (Kandilli'de "mag", AFAD'da "magnitude")
    final buyukluk = (json['mag'] ?? json['magnitude'])?.toDouble() ?? 0.0;

    // Lokasyon - AFAD'da title bir Map olabilir
    String lokasyon = 'Bilinmeyen Konum';
    if (json['title'] != null) {
      if (json['title'] is String) {
        lokasyon = json['title'] as String;
      } else if (json['title'] is Map) {
        // AFAD'da title bir Map ise, içinden text veya name alanını al
        final titleMap = json['title'] as Map<String, dynamic>;
        lokasyon = titleMap['text'] ?? 
                   titleMap['name'] ?? 
                   titleMap['location'] ?? 
                   titleMap.toString();
      }
    }

    // En yakın şehir
    String? enYakinSehir;
    if (kaynak == DepremKaynagi.kandilli) {
      // Kandilli formatı: location_properties.closestcity.name
      final closestCity = json['location_properties']?['closestcity'];
      if (closestCity is Map) {
        enYakinSehir = closestCity['name']?.toString();
      } else if (closestCity is String) {
        enYakinSehir = closestCity;
      }
    } else {
      // AFAD formatı: location_properties.closestCity (String veya Map olabilir)
      final closestCity = json['location_properties']?['closestCity'];
      if (closestCity is String) {
        enYakinSehir = closestCity;
      } else if (closestCity is Map) {
        enYakinSehir = closestCity['name'] ?? 
                       closestCity['text'] ?? 
                       closestCity.toString();
      }
    }

    // Koordinatlar (GeoJSON formatı: [longitude, latitude])
    double? enlem;
    double? boylam;
    if (json['geojson'] != null && json['geojson']['coordinates'] != null) {
      final coordinates = json['geojson']['coordinates'] as List;
      if (coordinates.length >= 2) {
        boylam = coordinates[0]?.toDouble(); // longitude
        enlem = coordinates[1]?.toDouble(); // latitude
      }
    }

    return Deprem(
      earthquakeId: json['earthquake_id']?.toString() ?? 
                    json['eventID']?.toString() ?? 
                    '',
      kaynak: kaynak,
      lokasyon: lokasyon,
      buyukluk: buyukluk,
      derinlik: (json['depth'] ?? 0.0)?.toDouble() ?? 0.0,
      enlem: enlem,
      boylam: boylam,
      enYakinSehir: enYakinSehir,
    );
  }
}


