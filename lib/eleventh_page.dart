import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:infertilityapp/app_ui.dart';
import 'fifth_page.dart'; // Import the fifth page to navigate to it
import 'twelfth_page.dart'; // Import the twelfth page to navigate to it
import 'comman.dart';

class EleventhPage extends StatefulWidget {
  final String userId; // Define userId variable
  final int dayDifference;

  // Constructor to receive the userId
  EleventhPage({required this.userId, required this.dayDifference});

  @override
  _EleventhPageState createState() => _EleventhPageState();
}

class _EleventhPageState extends State<EleventhPage> {
  List<dynamic> patients = [];
  List<dynamic> displayedPatients = []; // List to hold displayed patients
  List<dynamic> searchResults = []; // List to hold search results
  TextEditingController _searchController = TextEditingController();
  String imageUrl = '';

  @override
  void initState() {
    super.initState();
    // Fetch patient data when the widget is initialized
    fetchPatients();
  }

  // Method to fetch patient data from the server
  void fetchPatients() async {
    // Define your API endpoint URL
    String apiUrl = patientlist;

    try {
      // Make HTTP POST request to fetch patient data
      var response = await http.post(Uri.parse(apiUrl));

      // Check if the request was successful (status code 200)
      if (response.statusCode == 200) {
        // Parse the JSON response
        var data = json.decode(response.body);

        // Extract all patients' details from the response
        List<dynamic> patientsList = data['data'];

        // Take the latest 6 patients for display
        setState(() {
          patients = patientsList;
          displayedPatients = patientsList.reversed.take(6).toList();
        });
      } else {
        // Handle the error
        print("Error: ${response.statusCode}");
      }
    } catch (error) {
      // Handle any exceptions
      print("Error: $error");
    }
  }

  Future<String> fetchPatientImage(String userId) async {
    final response = await http.post(
      Uri.parse(viewpatient),
      body: {'userId': userId},
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status']) {
        var details = data['patientDetails'];
        if (details is List) {
          details = details.isNotEmpty ? details[0] : null;
        }
        final image = details is Map ? details['image'] : null;
        if (image != null && image.isNotEmpty) {
          return image.startsWith('http') ? image : '$patientimage$image';
        } else {
          return ''; // Return empty if image is null or empty
        }
      } else {
        print(data['message']);
        return '';
      }
    } else {
      print('Error: ${response.statusCode}');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => FifthPage(
                  userId: widget.userId,
                  dayDifference: widget.dayDifference)),
          ModalRoute.withName('/'),
        );
      },
      child: PageScaffold(
        title: 'Patients',
        decor: BgDecor.dots,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.ink),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FifthPage(
                        userId: widget.userId,
                        dayDifference: widget.dayDifference,
                      )), // Navigate to the fifth page
            );
          },
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  // Filter the patients list based on the search query
                  setState(() {
                    if (value.isEmpty) {
                      // If the search query is empty, display the latest patients
                      displayedPatients = patients.reversed.take(6).toList();
                    } else {
                      // Filter patients by both name and user ID
                      searchResults = patients
                          .where((patient) =>
                              patient['Name']
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              patient['Userid']
                                  .toString()
                                  .contains(value.toLowerCase()))
                          .toList();
                      // Display only older patients when searching
                      displayedPatients = searchResults
                          .where(
                              (patient) => !displayedPatients.contains(patient))
                          .toList();
                    }
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Search by name or ID',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
            ),
            Expanded(
              child: displayedPatients.isEmpty
                  ? const Center(
                      child: Text(
                        'No patients found',
                        style: TextStyle(color: AppColors.muted, fontSize: 15),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      itemCount: displayedPatients
                          .length, // Use displayedPatients list here
                      itemBuilder: (context, index) {
                        final patient = displayedPatients[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            elevation: 2,
                            shadowColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () {
                                // Get the userId and name of the selected patient
                                String userId =
                                    patient['Userid'].toString();
                                String name = patient['Name'];

                                // Navigate to the patient's details page and pass the User ID and name as parameters
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TwelfthPage(
                                      userId: userId,
                                      name: name,
                                      dayDifference: widget.dayDifference,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Row(
                                  children: [
                                    FutureBuilder<String>(
                                      future: fetchPatientImage(
                                          patient['Userid'].toString()),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return const SizedBox(
                                            width: 48,
                                            height: 48,
                                            child: Center(
                                              child: SizedBox(
                                                width: 22,
                                                height: 22,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ),
                                          );
                                        } else if (snapshot.hasError ||
                                            snapshot.data == '' ||
                                            snapshot.data == null) {
                                          return const IconBadge(
                                            icon: Icons.person_rounded,
                                            size: 48,
                                            iconSize: 26,
                                          );
                                        } else {
                                          return CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                AppColors.surface,
                                            backgroundImage: NetworkImage(
                                                snapshot.data!),
                                            onBackgroundImageError:
                                                (_, __) {},
                                            child: null,
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${patient['Name']}', // Display patient's name
                                            style: const TextStyle(
                                              fontSize: 15.5,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.ink,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'ID: ${patient['Userid']}', // Display patient's user ID
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: AppColors.muted),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right_rounded,
                                        color: AppColors.muted),
                                  ],
                                ),
                              ),
                            ),
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
