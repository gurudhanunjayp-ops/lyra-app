import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:infertilityapp/app_ui.dart';
import 'comman.dart';
import 'package:infertilityapp/addreports.dart';

class ReportsPage extends StatefulWidget {
  final String userId;
  final String name;
  final int dayDifference;

  ReportsPage(
      {required this.userId, required this.name, required this.dayDifference});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<String> imageUrls = [];
  List<String> dates = [];
  List<String> days = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch image URLs when the widget is initialized
    fetchImages();
  }

  Future<void> fetchImages() async {
    final Uri url = Uri.parse(
      '$viewimg?userid=${widget.userId}',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response
      final Map<String, dynamic> data = json.decode(response.body);
      print('Data fetched: $data'); // Debug print

      setState(() {
        // Adjusted to handle nested JSON structure
        if (data['status'] == true && data['images'] != null) {
          imageUrls =
              List<String>.from(data['images'].map((image) => image['url']));
          dates =
              List<String>.from(data['images'].map((image) => image['date']));
        }
        _isLoading = false;
      });
      print('Image URLs: $imageUrls'); // Debug print
      print('Dates: $dates'); // Debug print
    } else {
      // Handle error
      print('Failed to load images');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: 'View Reports',
      decor: BgDecor.dots,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : imageUrls.isEmpty
              ? const Center(
                  child: Text(
                    'No reports available',
                    style: TextStyle(color: AppColors.muted, fontSize: 15),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        elevation: 2,
                        shadowColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddReportsPage(
                                  userId: widget.userId,
                                  name: widget.name,
                                  imageUrl: imageUrls[index],
                                  dayDifference: widget.dayDifference,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrls[index],
                                    width: 64,
                                    height: 64,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const IconBadge(
                                      icon: Icons.broken_image_outlined,
                                      size: 64,
                                      iconSize: 28,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Scan Report',
                                        style: TextStyle(
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        dates[index], // Display date
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.muted,
                                        ),
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
    );
  }
}
