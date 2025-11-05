import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/deprem.dart';
import '../models/deprem_kaynagi.dart';
import '../models/siralama_tipi.dart';
import '../services/deprem_service.dart';
import '../services/bildirim_service.dart';

class DepremProvider with ChangeNotifier {
  final DepremService _service = DepremService();
  Timer? _periyodikTimer;

  DepremKaynagi _selectedKaynak = DepremKaynagi.kandilli;
  List<Deprem> _kandilliDepremler = [];
  List<Deprem> _afadDepremler = [];
  bool _isLoading = false;
  String? _error;
  int _yeniDepremSayisi = 0;
  String? _sonDepremId;

  // Filtreleme ve Sıralama
  double? _minBuyukluk;
  double? _maxDerinlik;
  DateTime? _minTarih;
  SiralamaTipi? _siralamaTipi;

  void _log(String message, {String tag = 'DepremProvider'}) {
    if (kDebugMode) {
      developer.log(message, name: tag);
      debugPrint('[$tag] $message');
    }
  }

  // Getters
  DepremKaynagi get selectedKaynak => _selectedKaynak;
  
  List<Deprem> get depremler {
    final hamListe = _selectedKaynak == DepremKaynagi.kandilli
        ? _kandilliDepremler
        : _afadDepremler;
    
    return _filtreleVeSirala(hamListe);
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get minBuyukluk => _minBuyukluk;
  double? get maxDerinlik => _maxDerinlik;
  DateTime? get minTarih => _minTarih;
  SiralamaTipi? get siralamaTipi => _siralamaTipi;
  int get yeniDepremSayisi => _yeniDepremSayisi;
  
  // Yeni deprem sayısını sıfırla
  void yeniDepremSayisiniSifirla() {
    _yeniDepremSayisi = 0;
    notifyListeners();
  }

  // Kaynak değiştir
  void changeKaynak(DepremKaynagi kaynak) {
    if (_selectedKaynak != kaynak) {
      _log('Kaynak değiştiriliyor: ${_selectedKaynak} -> $kaynak');
      _selectedKaynak = kaynak;
      _error = null;
      _yeniDepremSayisi = 0; // Kaynak değiştiğinde yeni deprem sayısını sıfırla
      _sonDepremId = null; // Kaynak değiştiğinde son deprem ID'sini sıfırla
      notifyListeners();

      // Eğer seçili kaynağın verileri yoksa, verileri çek
      if (kaynak == DepremKaynagi.kandilli && _kandilliDepremler.isEmpty) {
        _log('Kandilli verileri yok, çekiliyor...');
        fetchKandilliDepremler();
      } else if (kaynak == DepremKaynagi.afad && _afadDepremler.isEmpty) {
        _log('AFAD verileri yok, çekiliyor...');
        fetchAfadDepremler();
      } else {
        _log('${kaynak == DepremKaynagi.kandilli ? "Kandilli" : "AFAD"} verileri mevcut, ${_selectedKaynak == DepremKaynagi.kandilli ? _kandilliDepremler.length : _afadDepremler.length} deprem gösteriliyor');
      }
    }
  }

  // Kandilli depremlerini çek
  Future<void> fetchKandilliDepremler({bool bildirimGonder = false}) async {
    if (_isLoading) {
      _log('Kandilli veriler zaten yükleniyor, atlanıyor');
      return;
    }

    _log('Kandilli depremleri çekiliyor...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final depremler = await _service.getKandilliDepremler(limit: 100);
      
      // Yeni deprem kontrolü
      int yeniDepremSayisi = 0;
      if (_kandilliDepremler.isNotEmpty && depremler.isNotEmpty) {
        final ilkDepremId = depremler.first.earthquakeId;
        if (_sonDepremId != null && ilkDepremId != _sonDepremId) {
          // Yeni depremler var, kaç tane olduğunu bul
          final eskiIlkId = _kandilliDepremler.first.earthquakeId;
          for (var deprem in depremler) {
            if (deprem.earthquakeId == eskiIlkId) break;
            yeniDepremSayisi++;
          }
        }
      } else if (depremler.isNotEmpty && _sonDepremId == null) {
        // İlk yükleme, yeni deprem sayısını 0 yap
        yeniDepremSayisi = 0;
      }
      
      _kandilliDepremler = depremler;
      if (depremler.isNotEmpty) {
        _sonDepremId = depremler.first.earthquakeId;
      }
      _yeniDepremSayisi = yeniDepremSayisi;
      _error = null;
      _log('Kandilli: ${depremler.length} deprem başarıyla yüklendi (${yeniDepremSayisi} yeni)');
      
      // Bildirim kontrolü - sadece periyodik kontrol sırasında ve yeni depremler varsa
      if (bildirimGonder && yeniDepremSayisi > 0) {
        final yeniDepremler = depremler.take(yeniDepremSayisi).toList();
        _log('Yeni depremler bildirim için kontrol ediliyor: ${yeniDepremler.length} deprem');
        await BildirimService.kontrolEtVeBildir(yeniDepremler);
      } else {
        _log(bildirimGonder ? 'Periyodik kontrol - yeni deprem yok, bildirim gönderilmiyor' : 'Manuel refresh - bildirim gönderilmiyor');
      }
    } catch (e) {
      final errorMsg = e.toString();
      _error = errorMsg;
      _kandilliDepremler = [];
      _log('Kandilli veriler yüklenirken hata: $errorMsg', tag: 'ERROR');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // AFAD depremlerini çek
  Future<void> fetchAfadDepremler({bool bildirimGonder = false}) async {
    if (_isLoading) {
      _log('AFAD veriler zaten yükleniyor, atlanıyor');
      return;
    }

    _log('AFAD depremleri çekiliyor...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final depremler = await _service.getAfadDepremler(limit: 100);
      
      // Yeni deprem kontrolü
      int yeniDepremSayisi = 0;
      if (_afadDepremler.isNotEmpty && depremler.isNotEmpty) {
        final ilkDepremId = depremler.first.earthquakeId;
        if (_sonDepremId != null && ilkDepremId != _sonDepremId) {
          // Yeni depremler var, kaç tane olduğunu bul
          final eskiIlkId = _afadDepremler.first.earthquakeId;
          for (var deprem in depremler) {
            if (deprem.earthquakeId == eskiIlkId) break;
            yeniDepremSayisi++;
          }
        }
      } else if (depremler.isNotEmpty && _sonDepremId == null) {
        // İlk yükleme, yeni deprem sayısını 0 yap
        yeniDepremSayisi = 0;
      }
      
      _afadDepremler = depremler;
      if (depremler.isNotEmpty) {
        _sonDepremId = depremler.first.earthquakeId;
      }
      _yeniDepremSayisi = yeniDepremSayisi;
      _error = null;
      _log('AFAD: ${depremler.length} deprem başarıyla yüklendi (${yeniDepremSayisi} yeni)');
      
      // Bildirim kontrolü - sadece periyodik kontrol sırasında ve yeni depremler varsa
      if (bildirimGonder && yeniDepremSayisi > 0) {
        final yeniDepremler = depremler.take(yeniDepremSayisi).toList();
        _log('Yeni depremler bildirim için kontrol ediliyor: ${yeniDepremler.length} deprem');
        await BildirimService.kontrolEtVeBildir(yeniDepremler);
      } else {
        _log(bildirimGonder ? 'Periyodik kontrol - yeni deprem yok, bildirim gönderilmiyor' : 'Manuel refresh - bildirim gönderilmiyor');
      }
    } catch (e) {
      final errorMsg = e.toString();
      // Kullanıcı dostu hata mesajı
      if (errorMsg.contains('bağlanılamıyor') || errorMsg.contains('host lookup')) {
        _error = 'AFAD API\'ye bağlanılamıyor. İnternet bağlantınızı kontrol edin.';
      } else if (errorMsg.contains('zaman aşımı')) {
        _error = 'İstek zaman aşımına uğradı. Lütfen tekrar deneyin.';
      } else {
        _error = errorMsg;
      }
      _afadDepremler = [];
      _log('AFAD veriler yüklenirken hata: $errorMsg', tag: 'ERROR');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Yenile (mevcut kaynak için) - manuel refresh, bildirim göndermez
  Future<void> refresh() async {
    _log('Manuel yenileme işlemi başlatılıyor (${_selectedKaynak == DepremKaynagi.kandilli ? "Kandilli" : "AFAD"})');
    if (_selectedKaynak == DepremKaynagi.kandilli) {
      await fetchKandilliDepremler(bildirimGonder: false);
    } else {
      await fetchAfadDepremler(bildirimGonder: false);
    }
  }
  
  // Periyodik kontrol için özel refresh - bildirim gönderir
  Future<void> periyodikKontrolRefresh() async {
    _log('Periyodik kontrol yenileme işlemi başlatılıyor (${_selectedKaynak == DepremKaynagi.kandilli ? "Kandilli" : "AFAD"})');
    if (_selectedKaynak == DepremKaynagi.kandilli) {
      await fetchKandilliDepremler(bildirimGonder: true);
    } else {
      await fetchAfadDepremler(bildirimGonder: true);
    }
  }

  // İlk yükleme (Kandilli varsayılan)
  Future<void> initialize() async {
    _log('Provider başlatılıyor, Kandilli verileri yükleniyor...');
    await fetchKandilliDepremler();
    
    // Periyodik kontrol başlat
    _baslatPeriyodikKontrol();
  }
  
  // Periyodik kontrolü başlat
  Future<void> _baslatPeriyodikKontrol() async {
    _periyodikTimer?.cancel();
    final kontrolAraligi = await BildirimService.getKontrolAraligi();
    _log('Periyodik kontrol başlatılıyor: $kontrolAraligi dakika');
    
    _periyodikTimer = Timer.periodic(
      Duration(minutes: kontrolAraligi),
      (timer) async {
        _log('Periyodik kontrol çalışıyor...');
        await periyodikKontrolRefresh(); // Bildirim gönderen özel refresh
      },
    );
  }
  
  // Periyodik kontrolü yeniden başlat (ayarlar değiştiğinde)
  Future<void> periyodikKontroluYenile() async {
    await _baslatPeriyodikKontrol();
  }
  
  // Timer'ı temizle (ihtiyaç halinde)
  void temizle() {
    _periyodikTimer?.cancel();
    _periyodikTimer = null;
  }

  // Filtreleme ve Sıralama metodları
  List<Deprem> _filtreleVeSirala(List<Deprem> liste) {
    var sonuc = List<Deprem>.from(liste);

    // Filtreleme
    if (_minBuyukluk != null) {
      sonuc = sonuc.where((d) => d.buyukluk >= _minBuyukluk!).toList();
    }

    if (_maxDerinlik != null) {
      sonuc = sonuc.where((d) => d.derinlik <= _maxDerinlik!).toList();
    }

    if (_minTarih != null) {
      sonuc = sonuc.where((d) {
        if (d.tarih == null) return false;
        return d.tarih!.isAfter(_minTarih!) || d.tarih!.isAtSameMomentAs(_minTarih!);
      }).toList();
    }

    // Sıralama
    if (_siralamaTipi != null) {
      switch (_siralamaTipi!) {
        case SiralamaTipi.buyuklukAzalan:
          sonuc.sort((a, b) => b.buyukluk.compareTo(a.buyukluk));
          break;
        case SiralamaTipi.buyuklukArtan:
          sonuc.sort((a, b) => a.buyukluk.compareTo(b.buyukluk));
          break;
        case SiralamaTipi.tarihYeni:
          sonuc.sort((a, b) {
            if (a.tarih == null && b.tarih == null) return 0;
            if (a.tarih == null) return 1;
            if (b.tarih == null) return -1;
            return b.tarih!.compareTo(a.tarih!);
          });
          break;
        case SiralamaTipi.tarihEski:
          sonuc.sort((a, b) {
            if (a.tarih == null && b.tarih == null) return 0;
            if (a.tarih == null) return 1;
            if (b.tarih == null) return -1;
            return a.tarih!.compareTo(b.tarih!);
          });
          break;
        case SiralamaTipi.derinlikAzalan:
          sonuc.sort((a, b) => b.derinlik.compareTo(a.derinlik));
          break;
        case SiralamaTipi.derinlikArtan:
          sonuc.sort((a, b) => a.derinlik.compareTo(b.derinlik));
          break;
      }
    }

    return sonuc;
  }

  // Filtreleri ayarla
  void setMinBuyukluk(double? deger) {
    _minBuyukluk = deger;
    _log('Minimum büyüklük filtresi: $deger');
    notifyListeners();
  }

  void setMaxDerinlik(double? deger) {
    _maxDerinlik = deger;
    _log('Maksimum derinlik filtresi: $deger');
    notifyListeners();
  }

  void setMinTarih(DateTime? tarih) {
    _minTarih = tarih;
    _log('Minimum tarih filtresi: $tarih');
    notifyListeners();
  }

  void setSiralamaTipi(SiralamaTipi? tip) {
    _siralamaTipi = tip;
    _log('Sıralama tipi: $tip');
    notifyListeners();
  }

  // Filtreleri temizle
  void filtreleriTemizle() {
    _minBuyukluk = null;
    _maxDerinlik = null;
    _minTarih = null;
    _siralamaTipi = null;
    _log('Tüm filtreler temizlendi');
    notifyListeners();
  }
}


