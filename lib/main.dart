import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/deprem_provider.dart';
import 'screens/deprem_listesi_screen.dart';
import 'services/bildirim_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Bildirim servisini başlat
  await BildirimService.initialize();
  await BildirimService.requestPermission();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DepremProvider(),
      child: MaterialApp(
        title: 'Son Depremler',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const DepremListesiScreen(),
      ),
    );
  }
}
