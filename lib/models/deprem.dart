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
  final DateTime? tarih;

  Deprem({
    required this.earthquakeId,
    required this.kaynak,
    required this.lokasyon,
    required this.buyukluk,
    required this.derinlik,
    this.enlem,
    this.boylam,
    this.enYakinSehir,
    this.tarih,
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

    // Tarih parse etme (date, date_time, timestamp gibi alanları kontrol et)
    // API'den gelen tarihler genellikle UTC'dir, local time'a çeviriyoruz
    DateTime? tarih;
    if (json['date'] != null) {
      try {
        if (json['date'] is String) {
          // ISO 8601 formatı: "2024-01-15T10:30:00" veya "2024-01-15T10:30:00.000Z"
          final parsedDate = DateTime.parse(json['date'] as String);
          // UTC ise local time'a çevir, değilse olduğu gibi bırak
          tarih = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;
        } else if (json['date'] is int) {
          // Unix timestamp (milisaniye) - UTC olarak parse edip local time'a çevir
          tarih = DateTime.fromMillisecondsSinceEpoch(json['date'] as int, isUtc: true).toLocal();
        }
      } catch (e) {
        // Parse hatası durumunda null bırak
        tarih = null;
      }
    } else if (json['date_time'] != null) {
      try {
        if (json['date_time'] is String) {
          final parsedDate = DateTime.parse(json['date_time'] as String);
          tarih = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;
        } else if (json['date_time'] is int) {
          tarih = DateTime.fromMillisecondsSinceEpoch(json['date_time'] as int, isUtc: true).toLocal();
        }
      } catch (e) {
        tarih = null;
      }
    } else if (json['timestamp'] != null) {
      try {
        if (json['timestamp'] is String) {
          final parsedDate = DateTime.parse(json['timestamp'] as String);
          tarih = parsedDate.isUtc ? parsedDate.toLocal() : parsedDate;
        } else if (json['timestamp'] is int) {
          // Unix timestamp (saniye veya milisaniye kontrolü)
          final ts = json['timestamp'] as int;
          // 10 haneli ise saniye, 13 haneli ise milisaniye
          tarih = ts > 9999999999 
              ? DateTime.fromMillisecondsSinceEpoch(ts, isUtc: true).toLocal()
              : DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: true).toLocal();
        }
      } catch (e) {
        tarih = null;
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
      tarih: tarih,
    );
  }
}


