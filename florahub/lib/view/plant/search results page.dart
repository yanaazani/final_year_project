import 'package:flutter/material.dart';
import 'package:florahub/view/plant/plant%20detail%20page.dart';

class SearchResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final String familyName;

  SearchResultsPage(
      {Key? key, required this.searchResults, required this.familyName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter search results based on family name
    List<Map<String, dynamic>> filteredResults = searchResults
        .where((result) =>
            (result['family_common_name'] ?? result['family'])?.toLowerCase() ==
            familyName.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Add padding around the grid view
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Two columns
            crossAxisSpacing: 8.0, // Space between columns
            mainAxisSpacing: 8.0, // Space between rows
            childAspectRatio: 2 / 3, // Aspect ratio of the items
          ),
          itemCount: filteredResults.length,
          itemBuilder: (context, index) {
            var result = filteredResults[index];
            return Card(
              color: Colors.green[200], // Background color
              child: InkWell(
                onTap: () {
                  // Navigate to PlantDetailPage when tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PlantDetailPage(plantDetails: result),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: result['image_url'] != null
                          ? Image.network(
                              result['image_url'],
                              fit: BoxFit.cover,
                            )
                          : Container(), // Display an empty container if there is no image
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result['common_name'] ??
                                result['scientific_name'] ??
                                'Unknown',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.0),
                          Text(
                            'Category: ${result['family_common_name'] ?? result['family'] ?? 'Unknown'}',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
