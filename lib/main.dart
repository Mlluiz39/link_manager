import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/links/repository/link_repository.dart';
import 'features/links/viewmodel/link_viewmodel.dart';
import 'features/links/view/links_page.dart';

void main() {
  runApp(const LinkManagerApp());
}

class LinkManagerApp extends StatelessWidget {
  const LinkManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LinkViewModel(LinkRepository())),
      ],
      child: MaterialApp(
        title: 'Gerenciador de Links',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.purple,
          ).copyWith(secondary: Colors.purpleAccent),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.purple,
          ),
        ),
        home: const LinksPage(),
      ),
    );
  }
}
