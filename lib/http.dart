import 'dart:io';
import 'dart:convert';
import 'package:app5/board.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Http extends StatefulWidget {
  const Http({Key? key}) : super(key: key);

  @override
  State<Http> createState() {
    return _HttpState();
  }
}

class _HttpState extends State<Http> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _token = "";

  Future<bool> fetchDataWithCertificate() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    ByteData rootCertificateData = await rootBundle.load('assets/rootCA.pem');
    Uint8List rootCertificateBytes = rootCertificateData.buffer.asUint8List();

    ByteData certificateData =
        await rootBundle.load('assets/mkcert-client+5.pem');
    Uint8List certificateBytes = certificateData.buffer.asUint8List();

    ByteData keyData = await rootBundle.load('assets/mkcert-client+5-key.pem');
    Uint8List keyBytes = keyData.buffer.asUint8List();

    SecurityContext securityContext = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificatesBytes(rootCertificateBytes)
      ..useCertificateChainBytes(certificateBytes)
      ..usePrivateKeyBytes(keyBytes);

    HttpClient httpClient = HttpClient(context: securityContext);
    //..badCertificateCallback =
    //(X509Certificate cert, String host, int port) => true;

    final uri = Uri.parse('https://localhost:7258/home/login');
    final request = await httpClient.postUrl(uri);
    request.headers.set('Content-Type', 'application.json');
    final jsonBody =
        jsonEncode({'name': username, 'password': password, 'id': ""});

    request.write(jsonBody);

    try {
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseData =
            json.decode(await response.transform(utf8.decoder).join());
        final token = responseData['token'];
        setState(() {
          _token = token;
        });

        print('Login successful. Token: $_token');
        return true;
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      httpClient.close();
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello World Tester'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  bool authorized = await fetchDataWithCertificate();
                  if (authorized) {
                    Navigator.push(
                        context, MaterialPageRoute(builder: buildBoard));
                  }
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 20),
              Text('Token: $_token'),
            ],
          ),
        ),
      ),
    );
  }
}
