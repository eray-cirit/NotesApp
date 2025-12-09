import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/home_screen.dart';
import 'database/database_helper.dart';
import 'cubits/locations_cubit.dart';
import 'cubits/persons_cubit.dart';
import 'cubits/debts_cubit.dart';
import 'cubits/operations_cubit.dart';
import 'cubits/products_cubit.dart';
import 'cubits/stock_history_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Türkçe tarih formatlamasını başlat (LocaleData hatası için)
  await initializeDateFormatting('tr_TR', null);
  
  runApp(const BorcDefteriApp());
}

class BorcDefteriApp extends StatelessWidget {
  const BorcDefteriApp({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseHelper.instance;
    
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => LocationsCubit(db)),
        BlocProvider(create: (context) => PersonsCubit(db)),
        BlocProvider(create: (context) => DebtsCubit(db)),
        BlocProvider(create: (context) => OperationsCubit(db)),
        BlocProvider(create: (context) => ProductsCubit(db)),
        BlocProvider(create: (context) => StockHistoryCubit(db)),
      ],
      child: MaterialApp(
        title: 'Borç Defteri',
        debugShowCheckedModeBanner: false,
        
        // Lokalizasyon ayarları
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('tr', 'TR'), // Türkçe
          Locale('en', 'US'), // İngilizce (fallback)
        ],
        locale: const Locale('tr', 'TR'),
        
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1), // Modern indigo
            brightness: Brightness.light,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
            shape: CircleBorder(),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            elevation: 4,
            shape: CircleBorder(),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
