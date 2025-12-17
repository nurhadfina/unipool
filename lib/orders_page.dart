import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;


class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrdersPage> {
  final _formKey = GlobalKey<FormState>();

  // User Inputs
  GeoPoint? pickupLocation;
  GeoPoint? dropoffLocation;
  int seatsAvailable = 1;
  double maxFare = 0;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isLoading = false;

  // ----------------------------
  // Create Ride via Backend API
  // ----------------------------
  Future<void> createOrder() async {
    if (!_formKey.currentState!.validate()) return;

    if (pickupLocation == null || dropoffLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please set pickup & dropoff locations")),
      );
      return;
    }

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please choose date & time")),
      );
      return;
    }

    setState(() => isLoading = true);

    // Combine date + time into DateTime
    final DateTime departureTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    final rideData = {
      "userId": user.uid,
      "pickupLocation": {
        "latitude": pickupLocation!.latitude,
        "longitude": pickupLocation!.longitude
      },
      "dropoffLocation": {
        "latitude": dropoffLocation!.latitude,
        "longitude": dropoffLocation!.longitude
      },
      "seatsAvailable": seatsAvailable,
      "maxFare": maxFare,
      "departureTime": departureTime.toIso8601String(),
      "genderPreference": "any",
      "vehicleInfo": null,
      "status": "pending",
      "matchedWith": [],
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/create-ride'), // change to your backend URL
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(rideData),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order created successfully!")),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to create order: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isLoading = false);
  }

  // ----------------------------
  // Manual coordinates input
  // ----------------------------
  Future<void> setLocation(bool isPickup) async {
    TextEditingController latCtrl = TextEditingController();
    TextEditingController lngCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isPickup ? "Set Pickup" : "Set Dropoff"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: latCtrl,
              decoration: const InputDecoration(labelText: "Latitude"),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: lngCtrl,
              decoration: const InputDecoration(labelText: "Longitude"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latCtrl.text);
              final lng = double.tryParse(lngCtrl.text);
              if (lat != null && lng != null) {
                setState(() {
                  if (isPickup) {
                    pickupLocation = GeoPoint(lat, lng);
                  } else {
                    dropoffLocation = GeoPoint(lat, lng);
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // --------------------------------------
  // UI
  // --------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Order")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ListTile(
                title: Text(
                  pickupLocation == null
                      ? "Set Pickup Location"
                      : "Pickup: ${pickupLocation!.latitude}, ${pickupLocation!.longitude}",
                ),
                trailing: const Icon(Icons.location_on),
                onTap: () => setLocation(true),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(
                  dropoffLocation == null
                      ? "Set Dropoff Location"
                      : "Dropoff: ${dropoffLocation!.latitude}, ${dropoffLocation!.longitude}",
                ),
                trailing: const Icon(Icons.flag),
                onTap: () => setLocation(false),
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: "Seats Available"),
                keyboardType: TextInputType.number,
                initialValue: "1",
                onChanged: (value) => seatsAvailable = int.tryParse(value) ?? 1,
              ),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: "Max Fare (RM)"),
                keyboardType: TextInputType.number,
                onChanged: (value) => maxFare = double.tryParse(value) ?? 0,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text(selectedDate == null
                    ? "Choose Date"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                    initialDate: DateTime.now(),
                  );
                  if (date != null) setState(() => selectedDate = date);
                },
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text(selectedTime == null
                    ? "Choose Time"
                    : selectedTime!.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) setState(() => selectedTime = time);
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : createOrder,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Create Order"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
