import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  TextEditingController _cityController = TextEditingController();
  String _city = '';
  Map<String, dynamic>? _weatherData;
  final String _apiKey = '03daa5a371d5a2143842441d151d40f2'; // Replace with your API key

  Future<void> fetchWeatherForecast(String city) async {
    final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$city&appid=$_apiKey&units=metric');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          _weatherData = json.decode(response.body);
        });
      } else {
        setState(() {
          _weatherData = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('City not found!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching weather data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Weather Forecast'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Enter city',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _city = _cityController.text.trim();
                });
                if (_city.isNotEmpty) {
                  fetchWeatherForecast(_city);
                }
              },
              child: Text('Get Weather Forecast'),
            ),
            SizedBox(height: 20),
            _weatherData == null
                ? Text('Enter a city to get the weather forecast.')
                : WeatherForecastDetails(data: _weatherData!),
          ],
        ),
      ),
    );
  }
}

class WeatherForecastDetails extends StatelessWidget {
  final Map<String, dynamic> data;

  WeatherForecastDetails({required this.data});

  @override
  Widget build(BuildContext context) {
    final forecastList = data['list']; // List of forecast data every 3 hours
    final firstForecast = forecastList[0]; // First forecast item
    final temperature = firstForecast['main']['temp'];
    final description = firstForecast['weather'][0]['description'];
    final cityName = data['city']['name'];

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weather Forecast in $cityName',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Temperature: $temperature°C'),
            Text('Condition: ${description[0].toUpperCase()}${description.substring(1)}'),
          ],
        ),
      ),
    );
  }
}
