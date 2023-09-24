// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

final locator = GetIt.instance;

class ApiService {
  final String baseUrl;
  late SecurityContext securityContext;

  //Create an instance of ApiService with baseURL.
  static Future<ApiService> create(String baseUrl) async {
    final apiService = ApiService(baseUrl);
    await apiService._loadSecurityContext();
    return apiService;
  }

  ApiService(this.baseUrl);

  //This loads the security context with cerfiticates.
  Future<void> _loadSecurityContext() async {
    ByteData rootCertificateData = await rootBundle.load('assets/rootCA.pem');
    Uint8List rootCertificateBytes = rootCertificateData.buffer.asUint8List();

    ByteData certificateData =
        await rootBundle.load('assets/mkcertfinal-client+4-client.pem');
    Uint8List certificateBytes = certificateData.buffer.asUint8List();

    ByteData keyData =
        await rootBundle.load('assets/mkcertfinal-client+4-client-key.pem');
    Uint8List keyBytes = keyData.buffer.asUint8List();

    securityContext = SecurityContext(withTrustedRoots: false)
      ..setTrustedCertificatesBytes(rootCertificateBytes)
      ..useCertificateChainBytes(certificateBytes)
      ..usePrivateKeyBytes(keyBytes);
  }
  //This performs a login request with a username, password, and endpoint.
  Future<Map<String, dynamic>> login(
      String username, String password, String endpoint) async {
    await _loadSecurityContext();
    HttpClient httpClient = HttpClient(context: securityContext);

    final uri = Uri.parse('$baseUrl/$endpoint');
    final request = await httpClient.postUrl(uri);
    request.headers.set('Content-Type', 'application/json');
    final jsonBody =
        jsonEncode({'name': username, 'password': password, 'id': ""});

    request.write(jsonBody);
    try {
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseData =
            json.decode(await response.transform(utf8.decoder).join());
        return responseData;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    } finally {
      httpClient.close();
    }
  }
}

//This is my interface.
abstract class UserRepository {
  Future<String> login(String username, String password, String endpoint);
  Future<void> uploadPicture(File imageFile, String endpoint);
  Future<File> downloadNewestPicture(String endpoint);
  Future<void> deleteImages(String endpoint);
}

class DataRepository implements UserRepository {
  final ApiService apiService;

  DataRepository(this.apiService);

  //Here I implement the interface.
  @override
  Future<String> login(
      String username, String password, String endpoint) async {
    final responseData = await apiService.login(username, password, endpoint);
    final token = responseData['token'];
    return token;
  }

  @override
  Future<void> uploadPicture(File imageFile, String endpoint) async {
    try {
      await apiService._loadSecurityContext();
      final uri = Uri.parse('${apiService.baseUrl}/$endpoint');

      final httpClient = HttpClient(context: apiService.securityContext);

      final request = await httpClient.postUrl(uri);

      request.headers.set('Content-Type', 'multipart/form-data');

      final multipartFile = http.MultipartFile(
        'file',
        http.ByteStream(imageFile.openRead()),
        imageFile.lengthSync(),
        filename: imageFile.path.split('/').last,
      );

      final multipartRequest = http.MultipartRequest('POST', uri)
        ..files.add(multipartFile);

      final response = await multipartRequest.send();

      if (response.statusCode == 200) {
        print('Image upload successful');
      } else {
        throw Exception(
            'Image upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  @override
  Future<File> downloadNewestPicture(String endpoint) async {
    try {
      final uri = Uri.parse('${apiService.baseUrl}/$endpoint');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final imageUrl = response.body;
        final fileName = imageUrl.split('/').last;
        final file = File(fileName);

        await file.writeAsBytes(response.bodyBytes);

        return file;
      } else {
        throw Exception(
            'Image download failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error downloading image: $e');
    }
  }

  @override
  Future<void> deleteImages(String endpoint) async {
    try {
      final uri = Uri.parse('${apiService.baseUrl}/$endpoint');
      final response = await http.delete(uri);

      if (response.statusCode == 200) {
        print('All images have been deleted.');
      } else {
        throw Exception(
            'Image deletion failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting images: $e');
    }
  }

  //This sets the default endpoint.
  static final DataRepository _instance =
      DataRepository(ApiService('http://10.0.2.2:7258/home'));

  factory DataRepository.getInstance() {
    return _instance;
  }
}

class Http extends StatefulWidget {
  final UserRepository userRepository;
  const Http({Key? key, required this.userRepository}) : super(key: key);

  @override
  State<Http> createState() {
    return _HttpState();
  }
}

class _HttpState extends State<Http> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _token = "";

  Future<bool> fetchDataWithCertificate(String endpoint) async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    //This attempts to use the login method sending username, password and
    //endpoint and if successful recieves a token.
    try {
      String token =
          await widget.userRepository.login(username, password, endpoint);
      setState(() {
        _token = token;
      });

      if (token.isNotEmpty) {
        print('Login successful. Token: $_token');
        return true;
      }
    } catch (e) {
      print('Login failed: $e');
      return false;
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
                  bool authorized = await fetchDataWithCertificate('login');
                  if (authorized) {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Http(
                          userRepository: locator<UserRepository>(),
                        ),
                      ),
                    );
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
