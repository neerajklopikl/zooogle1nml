import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/company_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_page.dart'; // <-- ADD THIS IMPORT
import 'models/company.dart';    // <-- ADD THIS IMPORT
// import 'screens/company/company_selection_screen.dart'; // <-- REMOVE THIS IMPORT

// --- NEW: Mock Company data for bypassing login/selection ---
final _mockCompany = Company(
  id: 'mock_company_id',
  name: 'Demo Company',
  company_code: 'DEMO-1',
  gstin: '27AAAAA0000A1Z5',
  phone: '1234567890',
);
// -----------------------------------------------------------

Future<void> main() async {
  // Add this line for safe async operation before runApp
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.dev");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CompanyProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      // Use Builder to select the company on the provider before MaterialApp is built
      child: Builder(
        builder: (context) {
          // *** BYPASS LOGIC START ***
          Provider.of<CompanyProvider>(context, listen: false).selectCompany(_mockCompany);
          // *** BYPASS LOGIC END ***

          return Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false, // <-- THIS LINE REMOVES THE BANNER
                title: 'Zooogle',
                theme: ThemeData(
                  primarySwatch: Colors.deepPurple,
                  scaffoldBackgroundColor: const Color(0xFFFFF9F5),
                  appBarTheme: const AppBarTheme(
                    backgroundColor: Color(0xFFFFF9F5),
                    elevation: 0,
                    foregroundColor: Colors.black87,
                  ),
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    )
                  ),
                  cardTheme: const CardThemeData(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    )
                  ),
                ),
                darkTheme: ThemeData.dark().copyWith(
                  scaffoldBackgroundColor: const Color(0xFF121212),
                ),
                themeMode: themeProvider.themeMode,
                // --- MODIFIED TO BYPASS ---
                home: const HomePage(),
              );
            },
          );
        }
      ),
    );
  }
}