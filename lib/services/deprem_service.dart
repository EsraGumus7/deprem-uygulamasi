import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/deprem.dart';

class DepremService {
  static const String baseUrl = 'https://api.orhanaydogdu.com.tr/deprem';
  static const Duration requestTimeout = Duration(seconds: 15);

  void _log(String message, {String tag = 'DepremService'}) {
    if (kDebugMode) {
      developer.log(message, name: tag);
      debugPrint('[$tag] $message');
    }
  }

  // Kandilli'den son depremleri çek
  Future<List<Deprem>> getKandilliDepremler({int? limit}) async {
    // Limit parametresini URL'e ekle
    final limitParam = limit ?? 100;
    final url = Uri.parse('$baseUrl/kandilli/live?limit=$limitParam');
    _log('Kandilli API isteği başlatılıyor: $url');
    
    try {
      final response = await http.get(url).timeout(
        requestTimeout,
        onTimeout: () {
          _log('Kandilli API isteği zaman aşımına uğradı', tag: 'ERROR');
          throw Exception('İstek zaman aşımına uğradı');
        },
      );
      
      _log('Kandilli API yanıt kodu: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _log('Kandilli API JSON parse edildi');
        
        if (jsonData['status'] == true && jsonData['result'] != null) {
          final List<dynamic> depremlerJson = jsonData['result'];
          _log('Kandilli: ${depremlerJson.length} deprem bulundu');
          
          final depremler = depremlerJson
              .map((json) {
                try {
                  return Deprem.fromJson(json);
                } catch (e) {
                  _log('Deprem parse hatası: $e', tag: 'ERROR');
                  return null;
                }
              })
              .whereType<Deprem>()
              .toList();
          
          _log('Kandilli: ${depremler.length} deprem başarıyla parse edildi');
          
          // Limit varsa uygula
          if (limit != null && limit > 0) {
            final limited = depremler.take(limit).toList();
            _log('Kandilli: Limit uygulandı, ${limited.length} deprem döndürülüyor');
            return limited;
          }
          
          return depremler;
        } else {
          _log('Kandilli API yanıtında veri bulunamadı', tag: 'ERROR');
          throw Exception('API yanıtında veri bulunamadı');
        }
      } else {
        _log('Kandilli API hatası: ${response.statusCode} - ${response.body}', tag: 'ERROR');
        throw Exception('API hatası: ${response.statusCode}');
      }
    } catch (e) {
      _log('Kandilli verileri alınırken hata: $e', tag: 'ERROR');
      throw Exception('Kandilli verileri alınırken hata: $e');
    }
  }

  // AFAD'dan son depremleri çek
  Future<List<Deprem>> getAfadDepremler({int? limit}) async {
    // Limit parametresini URL'e ekle
    final limitParam = limit ?? 100;
    final url = Uri.parse('$baseUrl/afad/live?limit=$limitParam');
    _log('AFAD API isteği başlatılıyor: $url');
    
    try {
      final response = await http.get(url).timeout(
        requestTimeout,
        onTimeout: () {
          _log('AFAD API isteği zaman aşımına uğradı', tag: 'ERROR');
          throw Exception('İstek zaman aşımına uğradı');
        },
      );
      
      _log('AFAD API yanıt kodu: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        _log('AFAD API JSON parse edildi');
        
        if (jsonData['status'] == true && jsonData['result'] != null) {
          final List<dynamic> depremlerJson = jsonData['result'];
          _log('AFAD: ${depremlerJson.length} deprem bulundu');
          
          // İlk depremi örnek olarak logla
          if (depremlerJson.isNotEmpty) {
            _log('AFAD örnek JSON yapısı: ${depremlerJson[0]}', tag: 'DEBUG');
          }
          
          final depremler = depremlerJson
              .map((json) {
                try {
                  return Deprem.fromJson(json);
                } catch (e) {
                  _log('Deprem parse hatası: $e', tag: 'ERROR');
                  _log('Hatalı JSON: $json', tag: 'DEBUG');
                  return null;
                }
              })
              .whereType<Deprem>()
              .toList();
          
          _log('AFAD: ${depremler.length} deprem başarıyla parse edildi');
          
          // Limit varsa uygula
          if (limit != null && limit > 0) {
            final limited = depremler.take(limit).toList();
            _log('AFAD: Limit uygulandı, ${limited.length} deprem döndürülüyor');
            return limited;
          }
          
          return depremler;
        } else {
          _log('AFAD API yanıtında veri bulunamadı', tag: 'ERROR');
          throw Exception('API yanıtında veri bulunamadı');
        }
      } else {
        _log('AFAD API hatası: ${response.statusCode} - ${response.body}', tag: 'ERROR');
        throw Exception('API hatası: ${response.statusCode}');
      }
    } on http.ClientException catch (e) {
      _log('AFAD bağlantı hatası: $e', tag: 'ERROR');
      throw Exception('AFAD API\'ye bağlanılamıyor. İnternet bağlantınızı kontrol edin.');
    } catch (e) {
      _log('AFAD verileri alınırken hata: $e', tag: 'ERROR');
      throw Exception('AFAD verileri alınırken hata: $e');
    }
  }
}


