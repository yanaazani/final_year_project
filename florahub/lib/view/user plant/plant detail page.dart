import 'package:florahub/widgets/constants.dart';
import 'package:flutter/material.dart';

class PlantDetailPage extends StatelessWidget {
  final Map<String, dynamic> plantDetails;

  PlantDetailPage({Key? key, required this.plantDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text('Plant Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: size.width * 0.9,
                height: size.height * 0.8,
                decoration: BoxDecoration(
                  color: Constants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 350.0,
                          height: 350.0,
                          decoration: BoxDecoration(
                            color: Constants.primaryColor.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Positioned(
                          top: 1,
                          left: 10,
                          right: 10,
                          child: Container(
                            width: 350.0,
                            height: 350.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: plantDetails['image_url'] != null
                                  ? DecorationImage(
                                      image: NetworkImage(
                                          plantDetails['image_url']),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      plantDetails['common_name'] ??
                          plantDetails['scientific_name'] ??
                          'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Constants.blackColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Scientific Name: ${plantDetails['scientific_name'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Constants.blackColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Category: ${plantDetails['family_common_name'] ?? plantDetails['family'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Constants.blackColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Observations: ${plantDetails['observations'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Constants.blackColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      'Bibliography: ${plantDetails['bibliography'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Constants.blackColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
