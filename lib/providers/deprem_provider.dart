import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../models/deprem.dart';
import '../models/deprem_kaynagi.dart';
import '../services/deprem_service.dart';

class DepremProvider with ChangeNotifier {
  final DepremService _service = DepremService();

  DepremKaynagi _selectedKaynak = DepremKaynagi.kandilli;
  List<Deprem> _kandilliDepremler = [];
  List<Deprem> _afadDepremler = [];
  bool _isLoading = false;
  String? _error;

  void _log(String message, {String tag = 'DepremProvider'}) {
    if (kDebugMode) {
      developer.log(message, name: tag);
      debugPrint('[$tag] $message');
    }
  }

  // Getters
  DepremKaynagi get selectedKaynak => _selectedKaynak;
  List<Deprem> get depremler {
    return _selectedKaynak == DepremKaynagi.kandilli
        ? _kandilliDepremler
        : _afadDepremler;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Kaynak değiştir
  void changeKaynak(DepremKaynagi kaynak) {
    if (_selectedKaynak != kaynak) {
      _log('Kaynak değiştiriliyor: ${_selectedKaynak} -> $kaynak');
      _selectedKaynak = kaynak;
      _error = null;
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
  Future<void> fetchKandilliDepremler() async {
    if (_isLoading) {
      _log('Kandilli veriler zaten yükleniyor, atlanıyor');
      return;
    }

    _log('Kandilli depremleri çekiliyor...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final depremler = await _service.getKandilliDepremler();
      _kandilliDepremler = depremler;
      _error = null;
      _log('Kandilli: ${depremler.length} deprem başarıyla yüklendi');
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
  Future<void> fetchAfadDepremler() async {
    if (_isLoading) {
      _log('AFAD veriler zaten yükleniyor, atlanıyor');
      return;
    }

    _log('AFAD depremleri çekiliyor...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final depremler = await _service.getAfadDepremler();
      _afadDepremler = depremler;
      _error = null;
      _log('AFAD: ${depremler.length} deprem başarıyla yüklendi');
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

  // Yenile (mevcut kaynak için)
  Future<void> refresh() async {
    _log('Yenileme işlemi başlatılıyor (${_selectedKaynak == DepremKaynagi.kandilli ? "Kandilli" : "AFAD"})');
    if (_selectedKaynak == DepremKaynagi.kandilli) {
      await fetchKandilliDepremler();
    } else {
      await fetchAfadDepremler();
    }
  }

  // İlk yükleme (Kandilli varsayılan)
  Future<void> initialize() async {
    _log('Provider başlatılıyor, Kandilli verileri yükleniyor...');
    await fetchKandilliDepremler();
  }
}


