import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diacritic/diacritic.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  static const Color primaryColor = Color(0xFF054BF4);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: primaryColor,
          secondary: Colors.blueAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: primaryColor),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
        ),
      ),
      home: const CarSearchPage(),
    );
  }
}

class CarSearchPage extends StatefulWidget {
  const CarSearchPage({super.key});

  @override
  CarSearchPageState createState() => CarSearchPageState();
}

class CarSearchPageState extends State<CarSearchPage> {
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _combustivelController = TextEditingController();

  List<dynamic> cars = [];
  List<String> marcaSuggestions = [];
  List<String> modeloSuggestions = [];
  List<String> combustivelSuggestions = [];

  Future<List<String>> fetchMarcaSuggestions(String query) async {
    // Tratamento para Volkswagen/Wolkswagen
    if (query.toLowerCase().contains('wolkswagen') ||
        query.toLowerCase().contains('volkswagen')) {
      query = 'Volkswagen';
    }

    final url = 'http://localhost:8080/carros/search?marca=$query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> result = json.decode(response.body);
      // Usa um Set para remover duplicatas
      return result
          .map<String>((car) => car['Marca'].toString())
          .toSet()
          .toList();
    } else {
      return [];
    }
  }

  Future<List<String>> fetchModeloSuggestions(String query) async {
    final url = 'http://localhost:8080/carros/search?modelo=$query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> result = json.decode(response.body);
      return result.map<String>((car) => car['Modelo'].toString()).toList();
    } else {
      return [];
    }
  }

  Future<List<String>> fetchCombustivelSuggestions(String query) async {
    final url = 'http://localhost:8080/carros/search?combustivel=$query';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      List<dynamic> result = json.decode(response.body);
      return result
          .map<String>((car) => removeDiacritics(car['Combustivel'].toString()))
          .toSet()
          .toList();
    } else {
      return [];
    }
  }

  void fetchCars() async {
    String query = '';

    if (_marcaController.text.isNotEmpty) {
      query += 'marca=${_marcaController.text}&';
    }

    if (_modeloController.text.isNotEmpty) {
      query += 'modelo=${_modeloController.text}&';
    }

    if (_anoController.text.isNotEmpty) {
      query += 'ano=${_anoController.text}&';
    }

    if (_combustivelController.text.isNotEmpty) {
      query += 'combustivel=${_combustivelController.text}&';
    }

    final url = 'http://localhost:8080/carros/search?$query';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      setState(() {
        cars = json.decode(response.body);
      });
    } else {
      setState(() {
        cars = [];
      });
    }
  }

  final List<String> combustivelOptions = ['Gasolina', 'Álcool'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Buscar Carros'),
        backgroundColor: const Color(0xFF054BF4),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return fetchMarcaSuggestions(textEditingValue.text);
                    },
                    onSelected: (String selection) {
                      _marcaController.text = selection;
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                        ),
                        onEditingComplete: onEditingComplete,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return fetchModeloSuggestions(textEditingValue.text);
                    },
                    onSelected: (String selection) {
                      _modeloController.text = selection;
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                        ),
                        onEditingComplete: onEditingComplete,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _anoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return combustivelOptions.where((option) => option
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selection) {
                      _combustivelController.text = selection;
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Combustível',
                        ),
                        onEditingComplete: onEditingComplete,
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchCars,
              child: const Text('Pesquisar'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: cars.length,
                itemBuilder: (context, index) {
                  final car = cars[index];
                  final formattedPrice = car['Preco'] != null
                      ? NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                          .format(car['Preco'])
                      : 'Preço indisponível';
                  return ListTile(
                    title: Text(
                      car['Modelo'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Marca: ${car['Marca']}, Ano: ${car['Ano']}, Combustível: ${car['Combustivel']}, Preço: $formattedPrice',
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
