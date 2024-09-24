import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF054BF4),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF054BF4),
          secondary: Colors.blueAccent,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF054BF4),
            foregroundColor: Colors.white,
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Color(0xFF054BF4)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF054BF4)),
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
  _CarSearchPageState createState() => _CarSearchPageState();
}

class _CarSearchPageState extends State<CarSearchPage> {
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _anoController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  String? selectedCombustivel;

  List<dynamic> cars = [];

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

    if (selectedCombustivel != null) {
      query += 'combustivel=$selectedCombustivel&';
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
                  child: TextField(
                    controller: _marcaController,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _modeloController,
                    decoration: const InputDecoration(
                      labelText: 'Modelo',
                    ),
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
              ],
            ),
            DropdownButton<String>(
              value: selectedCombustivel,
              hint: const Text('Selecione o Combustível'),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCombustivel = newValue;
                });
              },
              items: <String>['Gasolina', 'Diesel', 'Álcool', 'Flex']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
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
                  return ListTile(
                    title: Text(car['Modelo']),
                    subtitle: Text(
                        'Marca: ${car['Marca']}, Ano: ${car['Ano']}, Combustível: ${car['Combustivel']}'),
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
