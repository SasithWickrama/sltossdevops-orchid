import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';

import 'package:orchid_test_app/providers/poles_provider.dart';

class RemovablePoles extends StatefulWidget {
  const RemovablePoles({super.key});

  @override
  State<RemovablePoles> createState() => _RemovablePolesState();
}

class _RemovablePolesState extends State<RemovablePoles> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<PoleProvider>(context, listen: false).loadData(context);
    });
  }

  String? _selectedMiniOPMC;
  String? _selectedLEA;
  String? _selectedArea;
  String? _selectedPoleType;
  String? _selectedPoleSize;
  // String? _setroadController;

  File? _image1;
  File? _image2;
  File? _image3;
  File? _image4;

  final picker = ImagePicker();

  Future getImage(int imageNumber) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        if (imageNumber == 1) {
          _image1 = File(pickedFile.path);
        } else if (imageNumber == 2) {
          _image2 = File(pickedFile.path);
        } else if (imageNumber == 3) {
          _image3 = File(pickedFile.path);
        } else if (imageNumber == 4) {
          _image4 = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      }
    });
  }

  void _showCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Colors.lightBlue[50],
              title: const Text('Select Categories',
                  style: TextStyle(color: Colors.blue)),
              content: SingleChildScrollView(
                child: ListBody(
                  children: Provider.of<PoleProvider>(context)
                      .categories
                      .map((category) {
                    return CheckboxListTile(
                      title: Text(category),
                      value: Provider.of<PoleProvider>(context)
                              .selectedCategories[category] ??
                          false,
                      onChanged: (bool? value) {
                        Provider.of<PoleProvider>(context, listen: false)
                            .toggleCategorySelection(category);
                        setState(() {}); // Update the UI
                      },
                      activeColor:
                          Colors.blue, // Color of the checkbox when selected
                      checkColor: Colors.white, // Color of the check mark
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text(
                    'Select All',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Provider.of<PoleProvider>(context, listen: false)
                        .selectAllCategories();
                    setState(() {});
                  },
                ),
                TextButton(
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Provider.of<PoleProvider>(context, listen: false)
                        .clearAllCategories();
                    setState(() {});
                  },
                ),
                TextButton(
                  child: const Text(
                    'OK',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Additional logic to handle the selected categories
                    List<String> selectedCategories =
                        Provider.of<PoleProvider>(context, listen: false)
                            .getSelectedCategories();
                    print('Selected Categories: $selectedCategories');
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final List<String> areaItems = ['Village', 'City'];
    // String? areaValue;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'REMOVABLE POLES',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body:
          // LoaderOverlay(
          //   useDefaultLoading: true,
          //   child:
          LoaderOverlay(
        useDefaultLoading: true,
        child: Container(
          width: MediaQuery.of(context).size.width, // Set width to screen width
          height:
              MediaQuery.of(context).size.height, // Set height to screen height
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
            // child: Consumer<PageOneProvider>(builder: (context, provider, child) { return
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dropdowns for selecting fields
                Row(
                  children: [
                    const Expanded(
                      flex:
                          2, // This controls the proportion of the space the text takes
                      child: Text(
                        'OPMC',
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
                      child: Consumer<PoleProvider>(
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
                              });
                              if (newvalue != null) {
                                provider
                                    .setSelectedMiniOPMC(newvalue.toString());
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
                          // _selectedArea = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 15),
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
                            child: Consumer<PoleProvider>(
                              builder: (context, provider, child) {
                                return DropdownButtonFormField<String>(
                                  value: _selectedLEA,
                                  items:
                                      provider.leaOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) async {
                                    setState(() {
                                      _selectedLEA = value;
                                      // _selectedMSAN = null;
                                    });
                                    if (value != null &&
                                        _selectedMiniOPMC != null) {
                                      provider.setLea(value.toString());
                                      // await provider.loadMsanData(
                                      //     context, _selectedMiniOPMC!, value);
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
                                // _selectedMSAN = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

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
                            child: Consumer<PoleProvider>(
                              builder: (context, provider, child) {
                                return DropdownButtonFormField<String>(
                                  value: _selectedArea,
                                  items:
                                      ['Village', 'City'].map((String value) {
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
                      flex:
                          1, // Flex value to control the space taken by this widget
                      child: const Text(
                        'Road Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                          fontSize: 16,
                          fontFamily: 'Arial',
                        ),
                      ),
                    ),
                    Expanded(
                      flex:
                          2, // Flex value to control the space taken by this widget
                      child: TextFormField(
                        controller:
                            Provider.of<PoleProvider>(context).roadController,
                        onChanged: (value) {
                          Provider.of<PoleProvider>(context, listen: false)
                              .setRoad(value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          Provider.of<PoleProvider>(context, listen: false)
                              .clearRoad();
                          // _roadController.text = '';
                        });
                      },
                    ),
                  ],
                ),

                // Space between dropdowns and radio buttons
                const SizedBox(height: 10),

                Row(
                  children: [
                    const Expanded(
                      flex:
                          1, // You can adjust the flex value to change the space distribution
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pole Type',
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
                            child: Consumer<PoleProvider>(
                              builder: (context, provider, child) {
                                return DropdownButtonFormField<String>(
                                  value: _selectedPoleType,
                                  items: ['Spun', 'Square'].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedPoleType = value;
                                    });
                                    if (value != null) {
                                      provider.setPoleType(value.toString());
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
                                _selectedPoleType = null;
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
                    const Expanded(
                      flex:
                          1, // You can adjust the flex value to change the space distribution
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pole Size',
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
                            child: Consumer<PoleProvider>(
                              builder: (context, provider, child) {
                                return DropdownButtonFormField<String>(
                                  value: _selectedPoleSize,
                                  items: ['5.5m', '6.7m', '7.4m', '8m', '9m']
                                      .map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _selectedPoleSize = value;
                                    });
                                    if (value != null) {
                                      provider.setPoleSize(value.toString());
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
                                _selectedPoleSize = null;
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Easiness to remove the pole',
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

                    const SizedBox(width: 10),

                    // Radio buttons for selecting one option
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showCategoryDialog(context),
                        child: const Text(
                          'Options',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Arial',
                          ),
                        ),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Color.fromARGB(255, 126, 155, 199),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Space between radio buttons and camera icons
                const SizedBox(height: 50),
                //camera 1
                Row(
                  children: [
                    Expanded(
                      flex:
                          2, // Adjust the flex as needed to give more space to the text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photo of the removable pole',
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
                      flex:
                          1, // Adjust the flex as needed to give proper space to the image
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _image1 != null
                              ? InkWell(
                                  onTap: () {
                                    getImage(1); // Open camera to retake image
                                  },
                                  child: Image.file(
                                    _image1!,
                                    height: 150,
                                    width: 150,
                                  ),
                                )
                              : IconButton(
                                  icon:
                                      Icon(Icons.add_a_photo_rounded, size: 90),
                                  onPressed: () {
                                    getImage(
                                        1); // Open camera to take the first image
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 50),

                Row(
                  children: [
                    Expanded(
                      flex:
                          2, // Adjust the flex as needed to give more space to the text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photo of the adjacent poles to which existing cables (in the removable pole) to be attached',
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
                      flex:
                          1, // Adjust the flex as needed to give proper space to the image
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _image2 != null
                              ? InkWell(
                                  onTap: () {
                                    getImage(2); // Open camera to retake image
                                  },
                                  child: Image.file(
                                    _image2!,
                                    height: 150,
                                    width: 150,
                                  ),
                                )
                              : IconButton(
                                  icon:
                                      Icon(Icons.add_a_photo_rounded, size: 90),
                                  onPressed: () {
                                    getImage(
                                        2); // Open camera to take the first image
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 50),

                Row(
                  children: [
                    Expanded(
                      flex:
                          2, // Adjust the flex as needed to give more space to the text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Photo evidence to identify the location',
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
                      flex:
                          1, // Adjust the flex as needed to give proper space to the image
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _image3 != null
                              ? InkWell(
                                  onTap: () {
                                    getImage(3); // Open camera to retake image
                                  },
                                  child: Image.file(
                                    _image3!,
                                    height: 150,
                                    width: 150,
                                  ),
                                )
                              : IconButton(
                                  icon:
                                      Icon(Icons.add_a_photo_rounded, size: 90),
                                  onPressed: () {
                                    getImage(
                                        3); // Open camera to take the first image
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 50),

                Row(
                  children: [
                    Expanded(
                      flex:
                          2, // Adjust the flex as needed to give more space to the text
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Other',
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
                      flex:
                          1, // Adjust the flex as needed to give proper space to the image
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _image4 != null
                              ? InkWell(
                                  onTap: () {
                                    getImage(4); // Open camera to retake image
                                  },
                                  child: Image.file(
                                    _image4!,
                                    height: 150,
                                    width: 150,
                                  ),
                                )
                              : IconButton(
                                  icon:
                                      Icon(Icons.add_a_photo_rounded, size: 90),
                                  onPressed: () {
                                    getImage(
                                        4); // Open camera to take the first image
                                  },
                                ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 50),

                // Space between camera icons and submit button
                const SizedBox(height: 30),

                // Submit button
                ElevatedButton(
                  onPressed: () {
                    context.loaderOverlay.show();
                    Provider.of<PoleProvider>(context, listen: false)
                        .submitData(context, _image1, _image2, _image3, _image4)
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
            ),
            // }),
          ),
        ),
      ),
    );
  }
}
