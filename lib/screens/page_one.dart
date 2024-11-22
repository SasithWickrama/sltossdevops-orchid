import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'dart:io';

import 'package:orchid_test_app/providers/page_one_provider.dart';

class PageOne extends StatefulWidget {
  final String sid;

  PageOne({required this.sid});

  @override
  _PageOneState createState() => _PageOneState();
}

class _PageOneState extends State<PageOne> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<PageOneProvider>(context, listen: false)
          .loadData(context);
    });
  }

  File? _image1;
  File? _image2;
  String? _selectedMiniOPMC;
  String? _selectedLEA;
  String? _selectedMSAN;
  String? _selectedArea;
  // String? _selectedCategory;

  // TextEditingController _roadNameController = TextEditingController();
  // String? _roadName;

  final picker = ImagePicker();

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

// class PageOne extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'CAPTURE',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: LoaderOverlay(
          useDefaultLoading: true,
          child: Container(
            width:
                MediaQuery.of(context).size.width, // Set width to screen width
            height: MediaQuery.of(context)
                .size
                .height, // Set height to screen height
            decoration: BoxDecoration(
              // Background image decoration
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/bg.png'), // Replace with your actual image path
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Consumer<PageOneProvider>(
                  builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Dropdowns for selecting fields
                    Row(
                      children: [
                        const Expanded(
                          flex:
                              2, // This controls the proportion of the space the text takes
                          child: Text(
                            'Mini OPMC',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          flex: 5,
                          child: Consumer<PageOneProvider>(
                            builder: (context, provider, child) {
                              return DropdownButtonFormField<String>(
                                value: _selectedMiniOPMC,
                                // hint: const Text('Select Mini OPMC'),
                                items: provider.options.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newvalue) async {
                                  setState(() {
                                    _selectedMiniOPMC = newvalue;
                                    _selectedLEA = null;
                                    _selectedMSAN = null;
                                  });
                                  if (newvalue != null) {
                                    provider.setSelectedMiniOPMC(
                                        newvalue.toString());
                                    await provider.loadLeaData(newvalue);
                                  }

                                  //   Provider.of<PageOneProvider>(context)
                                  //       .setSelectedMiniOPMC(newvalue);
                                  //   await Provider.of<PageOneProvider>(context,
                                  //           listen: false)
                                  //       .loadLeaData(newvalue);
                                  // }
                                },
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _selectedMiniOPMC = null;
                              _selectedLEA = null;
                              _selectedMSAN = null;
                              // _selectedArea = null;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LEA',
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
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                child: Consumer<PageOneProvider>(
                                  builder: (context, provider, child) {
                                    return DropdownButtonFormField<String>(
                                      value: _selectedLEA,
                                      items: provider.leaOptions
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) async {
                                        setState(() {
                                          _selectedLEA = value;
                                          _selectedMSAN = null;
                                        });
                                        if (value != null &&
                                            _selectedMiniOPMC != null) {
                                          provider.setLea(value.toString());
                                          await provider.loadMsanData(context,
                                              _selectedMiniOPMC!, value);
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
                                    _selectedLEA = null;
                                    _selectedMSAN = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // First Column for the label
                        const Expanded(
                          flex: 1,
                          child: Text(
                            'MSAN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 16,
                              fontFamily: 'Arial',
                            ),
                          ),
                        ),
                        // Second Column for the Dropdown and Clear button
                        Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              // DropdownButtonFormField with a fixed or flexible width
                              Expanded(
                                child: Consumer<PageOneProvider>(
                                  builder: (context, provider, child) {
                                    return DropdownButtonFormField<String>(
                                      value: _selectedMSAN,
                                      items: provider.msanOptions
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedMSAN = value;
                                        });
                                        if (value != null) {
                                          provider.setMsan(value.toString());
                                        }
                                      },
                                    );
                                  },
                                ),
                              ),
                              // IconButton for clearing the selection
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _selectedMSAN = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Expanded(
                          flex:
                              1, // You can adjust the flex value to change the space distribution
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Area',
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
                            width: 10), // Add spacing between text and dropdown
                        Expanded(
                          flex:
                              3, // Adjust flex value for dropdown to use more space
                          child: Row(
                            children: [
                              Expanded(
                                child: Consumer<PageOneProvider>(
                                  builder: (context, provider, child) {
                                    return DropdownButtonFormField<String>(
                                      value: _selectedArea,
                                      items: ['Village', 'City']
                                          .map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          _selectedArea = value;
                                        });
                                        if (value != null) {
                                          provider.setArea(value.toString());
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
                                    _selectedArea = null;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align items at the top
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Road Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontFamily: 'Arial',
                                ),
                              ),
                              TextFormField(
                                controller:
                                    Provider.of<PageOneProvider>(context)
                                        .roadController,
                                onChanged: (value) {
                                  Provider.of<PageOneProvider>(context,
                                          listen: false)
                                      .setRoad(value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Space between dropdowns and radio buttons
                    const SizedBox(height: 10),

                    // Radio buttons for selecting one option
                    const Text(
                      'Select one',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Custom font color
                        fontSize: 16, // Custom font size
                        fontFamily: 'Arial', // Custom font family
                      ),
                    ),

                    Consumer<PageOneProvider>(
                      builder: (context, provider, _) {
                        String selectedCategory = provider.selectedCategory;
                        Map<String, bool> category1Options =
                            provider.category1Options;
                        Map<String, bool> category2Options =
                            provider.category2Options;

                        Widget buildCategoryOptionsDialog(
                            Map<String, bool> options, String categoryType) {
                          return ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[900],
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.lightBlue[50],
                                    title: Text(
                                      categoryType == 'Category 1'
                                          ? 'Category 1 Options'
                                          : 'Category 2 Options',
                                      style: TextStyle(color: Colors.blue[900]),
                                    ),
                                    content: StatefulBuilder(
                                      builder: (BuildContext context,
                                          StateSetter setState) {
                                        return Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children:
                                              options.keys.map((String key) {
                                            return CheckboxListTile(
                                              title: Text(key),
                                              value: options[key],
                                              activeColor: Colors.blue,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  options[key] = value!;
                                                });
                                                if (categoryType ==
                                                    'Category 1') {
                                                  provider
                                                      .updateCategory1Option(
                                                          key, value!);
                                                } else {
                                                  provider
                                                      .updateCategory2Option(
                                                          key, value!);
                                                }
                                              },
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          if (categoryType == 'Category 1') {
                                            provider
                                                .selectAllCategory1Options();
                                          } else {
                                            provider
                                                .selectAllCategory2Options();
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Select All',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (categoryType == 'Category 1') {
                                            provider.clearCategory1Options();
                                          } else {
                                            provider.clearCategory2Options();
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Clear',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'OK',
                                          style: TextStyle(color: Colors.blue),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              categoryType == 'Category 1'
                                  ? 'Open Category 1 Options'
                                  : 'Open Category 2 Options',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: 'Arial',
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile(
                                    contentPadding: EdgeInsets.zero,
                                    visualDensity:
                                        const VisualDensity(horizontal: -4.0),
                                    dense: true,
                                    title: const Text(
                                      'Category 1',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 8, 83, 145),
                                        fontSize: 12,
                                        fontFamily: 'Arial',
                                      ),
                                    ),
                                    value: 'Category 1',
                                    groupValue: selectedCategory,
                                    activeColor: Colors.blue,
                                    onChanged: (value) {
                                      provider.setSelectedCategory(
                                          value.toString());
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile(
                                    contentPadding: EdgeInsets.zero,
                                    visualDensity:
                                        const VisualDensity(horizontal: -4.0),
                                    dense: true,
                                    title: const Text(
                                      'Category 2',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 8, 83, 145),
                                        fontSize: 12,
                                        fontFamily: 'Arial',
                                      ),
                                    ),
                                    value: 'Category 2',
                                    groupValue: selectedCategory,
                                    activeColor: Colors.blue,
                                    onChanged: (value) {
                                      provider.setSelectedCategory(
                                          value.toString());
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile(
                                    contentPadding: EdgeInsets.zero,
                                    visualDensity:
                                        const VisualDensity(horizontal: -4.0),
                                    dense: true,
                                    title: const Text(
                                      'Root Clearance',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 8, 83, 145),
                                        fontSize: 12,
                                        fontFamily: 'Arial',
                                      ),
                                    ),
                                    value: 'Root Clearance',
                                    groupValue: selectedCategory,
                                    activeColor: Colors.blue,
                                    onChanged: (value) {
                                      provider.setSelectedCategory(
                                          value.toString());
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (selectedCategory == 'Category 1')
                              buildCategoryOptionsDialog(
                                  category1Options, 'Category 1'),
                            if (selectedCategory == 'Category 2')
                              buildCategoryOptionsDialog(
                                  category2Options, 'Category 2'),
                          ],
                        );
                      },
                    ),

                    // Space between radio buttons and camera icons
                    const SizedBox(height: 10),

                    // Camera icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: _image1 != null
                              ? Image.file(
                                  _image1!,
                                  height: 150,
                                  width: 150,
                                )
                              : const Icon(Icons.add_a_photo_rounded, size: 90),
                          onPressed: () {
                            getImage(1); // For first image
                          },
                        ),
                        IconButton(
                          icon: _image2 != null
                              ? Image.file(
                                  _image2!,
                                  height: 150,
                                  width: 150,
                                )
                              : const Icon(Icons.add_a_photo_rounded, size: 90),
                          onPressed: () {
                            getImage(2); // For second image
                          },
                        ),
                      ],
                    ),

                    // Space between camera icons and submit button
                    const SizedBox(height: 30),

                    // Submit button
                    ElevatedButton(
                      onPressed: () {
                        context.loaderOverlay.show();
                        Provider.of<PageOneProvider>(context, listen: false)
                            .submitDataNew(context, _image1, _image2)
                            .whenComplete(() => context.loaderOverlay.hide());
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                          const Color.fromARGB(255, 13, 71, 161),
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
                    )
                  ],
                );
              }),
            ),
          ),
        ));
  }
}
