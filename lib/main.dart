import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Marker> markerList = [];
  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("ISS Tracker"),
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: const LatLng(0, 0),
          initialZoom: 4,
          onMapReady: () => getISSPosition()
        ),
        children: [
          TileLayer(
            urlTemplate: "INSERT YOUR MAPBOX URL",
          ),
          MarkerLayer(
            markers: markerList
          )
        ],
      ),

    );
  }

  getISSPosition() {
    Timer.periodic(const Duration(seconds: 1), (timer) async{
      final response = await http.get(Uri.parse('http://api.open-notify.org/iss-now.json'));
      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        double latitude = double.parse(parsedJson["iss_position"]["latitude"]);
        double longitude = double.parse(parsedJson["iss_position"]["longitude"]);
        setState(() {
          markerList.clear();
          markerList.add(
              Marker(
                  point: LatLng(latitude, longitude),
                  child: Image.asset("assets/images/iss.png", height: 500, fit: BoxFit.cover,)
              )
          );
          mapController.move(LatLng(latitude, longitude), 4);
        });
      }
    });
  }


}
