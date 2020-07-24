import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const request =
    'https://api.hgbrasil.com/finance?format=json-cors&key=78e32f2d';

void main() async {
  // print(await getData());

  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
            enabledBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
            focusedBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
            hintStyle: TextStyle(color: Colors.amber))),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double dolar;
  double euro;
  double bitcoin;

  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double reais = double.parse(text);
    dolarController.text = (reais / dolar).toStringAsFixed(2);
    euroController.text = (reais / euro).toStringAsFixed(2);
    bitcoinController.text = (reais / bitcoin).toStringAsFixed(6);
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double dolares = double.parse(text);
    realController.text = (dolar * dolares).toStringAsFixed(2);
    euroController.text = (dolares * dolar / euro).toStringAsFixed(2);
    bitcoinController.text = (dolares * dolar / bitcoin).toStringAsFixed(6);
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double euros = double.parse(text);
    realController.text = (euro * euros).toStringAsFixed(2);
    dolarController.text = (euro * euros / dolar).toStringAsFixed(2);
    bitcoinController.text = (euros * euros / bitcoin).toStringAsFixed(6);
  }

  void _bitcoinChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double bitcoins = double.parse(text);
    realController.text = (bitcoin * bitcoins).toStringAsFixed(2);
    dolarController.text = (bitcoins * bitcoin / dolar).toStringAsFixed(2);
    euroController.text = (bitcoins * bitcoin / euro).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = '';
    dolarController.text = '';
    euroController.text = '';
    bitcoinController.text = '';
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('\$ Conversor de Moedas \$'),
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text(
                  'Carregando dados',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.amber, fontSize: 25.0),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Erro ao carregar dados :(',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.amber, fontSize: 25.0),
                  ),
                );
              } else {
                dolar = snapshot.data['results']['currencies']['USD']['buy'];
                euro = snapshot.data['results']['currencies']['EUR']['buy'];
                bitcoin = snapshot.data['results']['currencies']['BTC']['buy'];
                debugPrint(dolar.toString());
                debugPrint(euro.toString());
                debugPrint(bitcoin.toString());
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  physics: BouncingScrollPhysics(),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 150,
                          color: Colors.amber,
                        ),
                        buildTextField(
                            'Reais', 'R\$', realController, _realChanged),
                        Divider(),
                        buildTextField(
                            'Dólares', 'US\$', dolarController, _dolarChanged),
                        Divider(),
                        buildTextField(
                            'Euros', '€', euroController, _euroChanged),
                        Divider(),
                        buildTextField('Bitcoins', 'BTC', bitcoinController,
                            _bitcoinChanged),
                      ]),
                );
              }
          }
        },
      ),
    );
  }
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function onChangeFunction) {
  return TextField(
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged: onChangeFunction,
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix + ' ',
    ),
    style: TextStyle(color: Colors.amber, fontSize: 25.0),
  );
}
