import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/deprem.dart';

class BildirimService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static bool _initialized = false;
  static const String _lastBildirimIdKey = 'last_bildirim_id';
  static const String _bildirimEsikKey = 'bildirim_esik';
  static const String _bildirimAktifKey = 'bildirim_aktif';
  static const String _kontrolAraligiKey = 'kontrol_araligi';

  // Bildirim servisini başlat
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Bildirime tıklandığında yapılacaklar
      },
    );

    _initialized = true;
  }

  // Bildirim izni iste (Android 13+ için)
  static Future<bool> requestPermission() async {
    if (await _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission() ??
        false) {
      return true;
    }
    return false;
  }

  // Bildirim eşiğini al
  static Future<double> getBildirimEsik() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_bildirimEsikKey) ?? 4.0;
  }

  // Bildirim eşiğini kaydet
  static Future<void> setBildirimEsik(double esik) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_bildirimEsikKey, esik);
  }

  // Bildirim aktif mi kontrol et
  static Future<bool> isBildirimAktif() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bildirimAktifKey) ?? true;
  }

  // Bildirim durumunu kaydet
  static Future<void> setBildirimAktif(bool aktif) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bildirimAktifKey, aktif);
  }

  // Kontrol aralığını al (dakika cinsinden)
  static Future<int> getKontrolAraligi() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kontrolAraligiKey) ?? 2; // Varsayılan 2 dakika
  }

  // Kontrol aralığını kaydet
  static Future<void> setKontrolAraligi(int dakika) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kontrolAraligiKey, dakika);
  }

  // Son bildirim verilen deprem ID'sini al
  static Future<String?> getLastBildirimId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastBildirimIdKey);
  }

  // Son bildirim verilen deprem ID'sini kaydet
  static Future<void> setLastBildirimId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastBildirimIdKey, id);
  }

  // Yeni depremleri kontrol et ve bildirim gönder
  static Future<void> kontrolEtVeBildir(List<Deprem> depremler) async {
    final aktif = await isBildirimAktif();
    if (!aktif) {
      debugPrint('[BildirimService] Bildirimler kapalı, kontrol edilmiyor');
      return;
    }

    final esik = await getBildirimEsik();
    final lastId = await getLastBildirimId();
    
    debugPrint('[BildirimService] Bildirim kontrolü: ${depremler.length} deprem, eşik: $esik');

    // Eşiği geçen yeni depremleri bul
    for (var deprem in depremler) {
      if (deprem.buyukluk >= esik) {
        debugPrint('[BildirimService] Eşik geçildi: ${deprem.buyukluk} >= $esik, ID: ${deprem.earthquakeId}');
        // Eğer bu deprem daha önce bildirilmediyse
        if (lastId == null || deprem.earthquakeId != lastId) {
          debugPrint('[BildirimService] Yeni deprem bildirimi gönderiliyor: ${deprem.buyukluk} - ${deprem.lokasyon}');
          await _gonderBildirim(deprem);
          await setLastBildirimId(deprem.earthquakeId);
          break; // Sadece ilk yeni depremi bildir
        } else {
          debugPrint('[BildirimService] Bu deprem zaten bildirilmiş: ${deprem.earthquakeId}');
        }
      }
    }
  }

  // Bildirim gönder
  static Future<void> _gonderBildirim(Deprem deprem) async {
    final androidDetails = AndroidNotificationDetails(
      'deprem_kanali',
      'Deprem Bildirimleri',
      channelDescription: 'Yüksek büyüklükteki depremler için bildirimler',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      showWhen: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      deprem.earthquakeId.hashCode,
      '${deprem.buyukluk.toStringAsFixed(1)} Büyüklüğünde Deprem',
      deprem.lokasyon,
      details,
    );
  }
}

