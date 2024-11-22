import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:orchid_test_app/providers/page_one_provider.dart';
import 'package:orchid_test_app/widgets/image_display.dart';
// import 'provider.dart'; // Update with your actual provider file

class DetailsScreen extends StatefulWidget {
  // final String sid;
  final String ref;

  const DetailsScreen({required this.ref, Key? key}) : super(key: key);

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final focusNode1 = FocusNode();
  final focusNode2 = FocusNode();
  final focusNode3 = FocusNode();
  final focusNode4 = FocusNode();

  @override
  void initState() {
    super.initState();

    // Lock orientation to portrait mode
    // SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PageOneProvider>(context, listen: false);
      provider.updateRef(widget.ref);
      provider.loadGetData(context, widget.ref);
      // provider.loadImages(widget.ref);
    });
  }

  @override
  void dispose() {
    // Unlock the orientation when this screen is disposed
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Future<void> _gotoLocation(double destLat, double destLon) async {
    if (await Permission.location.request().isGranted) {
      bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (isLocationEnabled) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high);
        double myLat = position.latitude;
        double myLon = position.longitude;

        Uri uri = Uri.parse(
            "http://maps.google.com/maps?saddr=$myLat,$myLon&daddr=$destLat,$destLon&dirflg=w");
        if (await canLaunch(uri.toString())) {
          await launch(uri.toString());
        } else {
          throw 'Could not launch $uri';
        }
      } else {
        _showDialog('Location Error', 'Location services are disabled.');
      }
    } else {
      _showDialog('Permission Denied', 'Location permissions are denied.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  final picker = ImagePicker();
  File? _image1;
  File? _image2;

  String? _selectedWby;
  String? _selectedPay;

  Future getImage(int imageNumber) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        if (imageNumber == 1) {
          _image1 = File(pickedFile.path);
        } else if (imageNumber == 2) {
          _image2 = File(pickedFile.path);
        }
      } else {
        print('No image selected.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<PageOneProvider>(
                  builder: (context, provider, child) {
                    if (provider.test == null) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var data = provider.test[
                        0]; // Assuming data is a list and we want the first item

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Table(
                            columnWidths: {
                              0: FlexColumnWidth(
                                  2), // Adjust the width of the first column
                              1: FlexColumnWidth(
                                  3), // Adjust the width of the second column
                            },
                            children: [
                              TableRow(
                                children: [
                                  Text(
                                    'Reference:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    data['REGID'] ?? '',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(
                                      height: 8), // Add spacing between rows
                                  SizedBox(height: 8),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'OPMC:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    data['MINIOPMC'] ?? '',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(height: 8),
                                  SizedBox(height: 8),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'LEA:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    data['LEA'] ?? '',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(height: 8),
                                  SizedBox(height: 8),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'MSAN:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    data['MSAN'] ?? '',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(height: 8),
                                  SizedBox(height: 8),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'Area:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    data['AREA'] ?? '',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(height: 8),
                                  SizedBox(height: 8),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'Road Name:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    data['ROAD_NAME'] ?? '',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(height: 8),
                                  SizedBox(height: 8),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Text(
                                    'Type:',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                  Text(
                                    data['CATEGORY1'] ?? '',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.black),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  SizedBox(height: 8),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Text('Images:'),
                          ImageDisplay(ref: widget.ref),

                          SizedBox(height: 20),
                          Center(
                            child: ElevatedButton(
                              onPressed: () {
                                double lat = double.parse(data['LAT']);
                                double lon = double.parse(data['LON']);
                                _gotoLocation(lat, lon);
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all<Color>(
                                  const Color.fromARGB(255, 13, 71, 161),
                                ),
                              ),
                              child: const Text(
                                'ROUTE TO LOCATION',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Arial',
                                ),
                              ),
                            ),
                          ),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),
                          SizedBox(height: 40),
                          // LoaderOverlay(
                          //   useDefaultLoading: true,
                          //   child:
                          Form(
                            // key: GlobalKey<FormState>(),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'Comments',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 16,
                                          fontFamily: 'Arial',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller:
                                            Provider.of<PageOneProvider>(
                                                    context)
                                                .commentsController,
                                        onChanged: (value) {
                                          Provider.of<PageOneProvider>(context,
                                                  listen: false)
                                              .setComment(value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'Starting Point',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 16,
                                          fontFamily: 'Arial',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller:
                                            Provider.of<PageOneProvider>(
                                                    context)
                                                .startController,
                                        onChanged: (value) {
                                          Provider.of<PageOneProvider>(context,
                                                  listen: false)
                                              .setStart(value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'Ending Point',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 16,
                                          fontFamily: 'Arial',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller:
                                            Provider.of<PageOneProvider>(
                                                    context)
                                                .endController,
                                        onChanged: (value) {
                                          Provider.of<PageOneProvider>(context,
                                                  listen: false)
                                              .setEnd(value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: const Text(
                                        'Length',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                          fontSize: 16,
                                          fontFamily: 'Arial',
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        controller:
                                            Provider.of<PageOneProvider>(
                                                    context)
                                                .cableController,
                                        onChanged: (value) {
                                          Provider.of<PageOneProvider>(context,
                                                  listen: false)
                                              .setCable(value);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Expanded(
                                      flex:
                                          1, // You can adjust the flex value to change the space distribution
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Work Done By',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                              fontSize: 15,
                                              fontFamily: 'Arial',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            40), // Add spacing between text and dropdown
                                    Expanded(
                                      flex:
                                          3, // Adjust flex value for dropdown to use more space
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Consumer<PageOneProvider>(
                                              builder:
                                                  (context, provider, child) {
                                                return DropdownButtonFormField<
                                                    String>(
                                                  value: _selectedWby,
                                                  items: ['SLT', 'Contractor']
                                                      .map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _selectedWby = value;
                                                    });
                                                    if (value != null) {
                                                      provider.setWby(
                                                          value.toString());
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              setState(() {
                                                _selectedWby = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    const Expanded(
                                      flex:
                                          1, // You can adjust the flex value to change the space distribution
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Payment',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                              fontSize: 16,
                                              fontFamily: 'Arial',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                        width:
                                            40), // Add spacing between text and dropdown
                                    Expanded(
                                      flex:
                                          3, // Adjust flex value for dropdown to use more space
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Consumer<PageOneProvider>(
                                              builder:
                                                  (context, provider, child) {
                                                return DropdownButtonFormField<
                                                    String>(
                                                  value: _selectedPay,
                                                  items: ['Payed', 'Not Payed']
                                                      .map((String value) {
                                                    return DropdownMenuItem<
                                                        String>(
                                                      value: value,
                                                      child: Text(value),
                                                    );
                                                  }).toList(),
                                                  onChanged: (String? value) {
                                                    setState(() {
                                                      _selectedPay = value;
                                                    });
                                                    if (value != null) {
                                                      provider.setPay(
                                                          value.toString());
                                                    }
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.clear),
                                            onPressed: () {
                                              setState(() {
                                                _selectedPay = null;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        getImage(1); // For first image
                                      },
                                      child: _image1 != null
                                          ? Image.file(
                                              _image1!,
                                              height: 150,
                                              width: 150,
                                            )
                                          : const Icon(
                                              Icons.add_a_photo_rounded,
                                              size: 90,
                                            ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        getImage(2); // For second image
                                      },
                                      child: _image2 != null
                                          ? Image.file(
                                              _image2!,
                                              height: 150,
                                              width: 150,
                                            )
                                          : const Icon(
                                              Icons.add_a_photo_rounded,
                                              size: 90,
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Center(
                                  child: SizedBox(
                                    width: 350,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        context.loaderOverlay.show();
                                        Provider.of<PageOneProvider>(context,
                                                listen: false)
                                            .submitDetailData(
                                                context, _image1, _image2)
                                            .whenComplete(() =>
                                                context.loaderOverlay.hide());
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                          const Color.fromARGB(
                                              255, 13, 71, 161),
                                        ),
                                      ),
                                      child: const Text(
                                        'Submit',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: 'Arial',
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
