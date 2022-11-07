import 'package:alphanum_comparator/alphanum_comparator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lowermyrx/bloc/drug_selection_bloc.dart';
import 'package:lowermyrx/constants.dart';
import 'package:lowermyrx/screens/prices_screen.dart';
import 'package:lowermyrx/repos/drug_structure_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrugSelectionScreen extends StatefulWidget {
  final String displayName;
  final String seoName;

  const DrugSelectionScreen({
    Key? key,
    required this.displayName,
    required this.seoName,
  }) : super(key: key);

  @override
  State<DrugSelectionScreen> createState() => _DrugSelectionScreenState();
}

class _DrugSelectionScreenState extends State<DrugSelectionScreen> {
  final DrugStructureRepository _drugStructureRepository =
      DrugStructureRepository();
  TextEditingController _zipCodeController = TextEditingController();
  TextEditingController _brandController = TextEditingController();
  TextEditingController _formController = TextEditingController();
  TextEditingController _dosageController = TextEditingController();
  TextEditingController _quantityController = TextEditingController();
  FixedExtentScrollController _brandScrollController =
      FixedExtentScrollController(initialItem: 0);
  FixedExtentScrollController _formScrollController =
      FixedExtentScrollController(initialItem: 0);
  FixedExtentScrollController _dosageScrollController =
      FixedExtentScrollController(initialItem: 0);
  FixedExtentScrollController _quantityScrollController =
      FixedExtentScrollController(initialItem: 0);
  int brandsIndex = 0;
  int formsIndex = 0;
  int dosageIndex = 0;
  int quantityIndex = 0;

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.white,
        // Use a SafeArea widget to avoid system overlaps.
        child: DefaultTextStyle(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: CupertinoColors.black,
            fontSize: 18.0,
          ),
          child: GestureDetector(
            // Blocks taps from propagating to the modal sheet and popping.
            onTap: () {},
            child: SafeArea(
              top: false,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getZipcode() async {
    final prefs = await SharedPreferences.getInstance();

    final String? zipcode = prefs.getString('zipcode');
    if (zipcode != null) {
      _zipCodeController.text = zipcode;
    }
  }

  @override
  void initState() {
    getZipcode();

    super.initState();
  }

  @override
  void dispose() {
    _brandScrollController.dispose();
    _dosageScrollController.dispose();
    _formScrollController.dispose();
    _quantityScrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.displayName,
        ),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => DrugSelectionBloc(
          _drugStructureRepository,
        )..add(
            GetDrugStructure(
              seoName: widget.seoName,
            ),
          ),
        child: BlocConsumer<DrugSelectionBloc, DrugSelectionState>(
          listener: (context, state) {
            if (state is ZipCodeLoaded) {
              _zipCodeController.text = state.zipCode;
            } else if (state is BrandUpdated) {
              _brandController.text = state.brand;

              String drugName = _brandController.text;
              if (drugName.contains('(Brand)')) {
                drugName = drugName.replaceAll(' (Brand)', '');
              } else if (drugName.contains('(Generic)')) {
                drugName = drugName.replaceAll(' (Generic)', '');
              }

              if (state.form.isNotEmpty) {
                for (int i = 0; i < state.form.length; i++) {
                  if (state.form[i][0] == drugName)
                    _formController.text = state.form[i][1];
                }
              }

              if (state.dosage.isNotEmpty) {
                for (int i = 0; i < state.dosage.length; i++) {
                  for (int j = 0; j < state.dosage[i].length; j++) {
                    if (state.dosage[i][j][0] == drugName) {
                      if (state.dosage[i][j][1] == _formController.text)
                        _dosageController.text = state.dosage[i][j][2];
                    }
                  }
                }
              }

              if (state.quantity.isNotEmpty) {
                for (int i = 0; i < state.quantity.length; i++) {
                  for (int j = 0; j < state.quantity[i].length; j++) {
                    for (int k = 0; k < state.quantity[i][j].length; k++) {
                      if (state.quantity[i][j][k][0] == drugName) {
                        if (state.quantity[i][j][k][1] ==
                            _formController.text) {
                          if (state.quantity[i][j][k][2] ==
                              _dosageController.text)
                            _quantityController.text =
                                state.quantity[i][j][k][3];
                        }
                      }
                    }
                  }
                }
              }
            } else if (state is BrandRemoved) {
              _brandController.text = '';
              _dosageController.text = '';
              _formController.text = '';
              _quantityController.text = '';
            } else if (state is FormUpdated) {
              _formController.text = state.form;

              String drugName = _brandController.text;
              if (drugName.contains('(Brand)')) {
                drugName = drugName.replaceAll(' (Brand)', '');
              } else if (drugName.contains('(Generic)')) {
                drugName = drugName.replaceAll(' (Generic)', '');
              }

              if (state.dosage.isNotEmpty) {
                for (int i = 0; i < state.dosage.length; i++) {
                  for (int j = 0; j < state.dosage[i].length; j++) {
                    if (state.dosage[i][j][0] == drugName) {
                      if (state.dosage[i][j][1] == _formController.text)
                        _dosageController.text = state.dosage[i][j][2];
                    }
                  }
                }
              }

              if (state.quantity.isNotEmpty) {
                for (int i = 0; i < state.quantity.length; i++) {
                  for (int j = 0; j < state.quantity[i].length; j++) {
                    for (int k = 0; k < state.quantity[i][j].length; k++) {
                      if (state.quantity[i][j][k][0] == drugName) {
                        if (state.quantity[i][j][k][1] ==
                            _formController.text) {
                          if (state.quantity[i][j][k][2] ==
                              _dosageController.text)
                            _quantityController.text =
                                state.quantity[i][j][k][3];
                        }
                      }
                    }
                  }
                }
              }
            } else if (state is DosageUpdated) {
              _dosageController.text = state.dosage;

              String drugName = _brandController.text;
              if (drugName.contains('(Brand)')) {
                drugName = drugName.replaceAll(' (Brand)', '');
              } else if (drugName.contains('(Generic)')) {
                drugName = drugName.replaceAll(' (Generic)', '');
              }

              if (state.quantity.isNotEmpty) {
                for (int i = 0; i < state.quantity.length; i++) {
                  for (int j = 0; j < state.quantity[i].length; j++) {
                    for (int k = 0; k < state.quantity[i][j].length; k++) {
                      if (state.quantity[i][j][k][0] == drugName) {
                        if (state.quantity[i][j][k][1] ==
                            _formController.text) {
                          if (state.quantity[i][j][k][2] ==
                              _dosageController.text)
                            _quantityController.text =
                                state.quantity[i][j][k][3];
                        }
                      }
                    }
                  }
                }
              }
            } else if (state is QuantityUpdated) {
              _quantityController.text = state.quantity;
            }
          },
          builder: (context, state) {
            if (state is DrugSelectionLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is DrugSelectionLoaded) {
              List<String> brands = [];
              brands.add('-');
              int numberOfBrands = state.drugStructure.value!.length;
              for (int i = 0; i < numberOfBrands; i++) {
                String drugName = state.drugStructure.value![i].key!;
                bool isGeneric = state.drugStructure.value![i].value![0]
                    .value![0].value![0].value!.isGeneric!;
                if (isGeneric) {
                  brands.add(drugName + ' (Generic)');
                } else if (!isGeneric) {
                  brands.add(drugName + ' (Brand)');
                }
              }
              brands.sort();

              if (brands.length == 1) {
                _brandController.text = brands[0];
              }

              List<List<String>> forms = [];
              for (int i = 0; i < numberOfBrands; i++) {
                String drugName = state.drugStructure.value![i].key!;
                List<String> formArray = [];
                forms.add([]);
                forms[i].add(drugName);
                int numberOfForms = state.drugStructure.value![i].value!.length;
                for (int j = 0; j < numberOfForms; j++) {
                  formArray.add(state.drugStructure.value![i].value![j].key!);
                }

                for (int j = 0; j < numberOfForms; j++) {
                  forms[i].add(formArray[j]);
                }
              }

              forms = forms.toSet().toList();

              List<List<List<String>>> dosage = [];
              for (int i = 0; i < numberOfBrands; i++) {
                dosage.add([]);
                int numberOfForms = state.drugStructure.value![i].value!.length;
                for (int j = 0; j < numberOfForms; j++) {
                  dosage[i].add([]);
                  String drugName = state.drugStructure.value![i].key!;
                  dosage[i][j].add(drugName);
                  String formType =
                      state.drugStructure.value![i].value![j].key!;

                  dosage[i][j].add(formType);
                  int numberOfDosages =
                      state.drugStructure.value![i].value![j].value!.length;
                  List<String> dosagesList = [];
                  for (int k = 0; k < numberOfDosages; k++) {
                    String dose =
                        state.drugStructure.value![i].value![j].value![k].key!;
                    dosagesList.add(dose);
                  }
                  dosagesList.sort(AlphanumComparator.compare);
                  for (int k = 0; k < dosagesList.length; k++) {
                    dosage[i][j].add(dosagesList[k]);
                  }
                }
              }

              List<List<List<List<String>>>> quantity = [];
              for (int i = 0; i < numberOfBrands; i++) {
                quantity.add([]);
                String drugName = state.drugStructure.value![i].key!;
                int numberOfForms = state.drugStructure.value![i].value!.length;
                for (int j = 0; j < numberOfForms; j++) {
                  quantity[i].add([]);
                  String formType =
                      state.drugStructure.value![i].value![j].key!;
                  int numberOfDosages =
                      state.drugStructure.value![i].value![j].value!.length;
                  for (int k = 0; k < numberOfDosages; k++) {
                    quantity[i][j].add([]);
                    String dose =
                        state.drugStructure.value![i].value![j].value![k].key!;
                    quantity[i][j][k].add(drugName);
                    quantity[i][j][k].add(formType);
                    quantity[i][j][k].add(dose);
                    int numberOfQuantity = state.drugStructure.value![i]
                        .value![j].value![k].value!.length;

                    List<String> quantityList = [];
                    for (int l = 0; l < numberOfQuantity; l++) {
                      String quantities = state.drugStructure.value![i]
                          .value![j].value![k].value![l].key!;
                      quantityList.add(quantities);
                    }
                    quantityList.sort(AlphanumComparator.compare);
                    for (int l = 0; l < quantityList.length; l++) {
                      quantity[i][j][k].add(quantityList[l].toString());
                    }
                  }
                }
              }

              return GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);

                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 30.0,
                      left: 30,
                      right: 30,
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoSearchTextField(
                                autocorrect: false,
                                controller: _zipCodeController,
                                prefixIcon: Icon(Icons.gps_fixed),
                                itemColor: kGreenPrimary,
                                placeholder: 'Zip Code',
                                padding: const EdgeInsets.only(
                                  top: 15,
                                  bottom: 15,
                                  left: 15,
                                  right: 15,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  try {
                                    String zipCode =
                                        await _getZipCodeFromGeolocation();
                                    print(zipCode);
                                    BlocProvider.of<DrugSelectionBloc>(context)
                                        .add(
                                      UpdateZipCode(
                                        zipCode: zipCode,
                                        drugStructure: state.drugStructure,
                                      ),
                                    );
                                  } on Exception catch (e) {
                                    Fluttertoast.showToast(
                                      msg: '  $e  ',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      timeInSecForIosWeb: 1,
                                      textColor: Colors.white,
                                      fontSize: 16.0,
                                    );
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    kGreenPrimary,
                                  ),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.gps_not_fixed,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: InkWell(
                            onTap: () {
                              _brandScrollController.dispose();
                              _brandScrollController =
                                  FixedExtentScrollController(
                                      initialItem: brandsIndex);

                              _showDialog(
                                CupertinoPicker(
                                  itemExtent: 40,
                                  scrollController: _brandScrollController,
                                  // This is called when selected item is changed.
                                  onSelectedItemChanged: (int selectedItem) {
                                    brandsIndex = selectedItem;
                                    if (selectedItem == 0) {
                                      BlocProvider.of<DrugSelectionBloc>(
                                              context)
                                          .add(RemoveBrand(
                                        drugStructure: state.drugStructure,
                                      ));
                                    } else {
                                      BlocProvider.of<DrugSelectionBloc>(
                                              context)
                                          .add(
                                        UpdateBrand(
                                          brand: brands[selectedItem],
                                          form: forms,
                                          dosage: dosage,
                                          quantity: quantity,
                                          drugStructure: state.drugStructure,
                                        ),
                                      );
                                    }
                                  },
                                  children: List<Widget>.generate(
                                    brands.length,
                                    (int index) {
                                      return Container(
                                        height: 50,
                                        child: Center(
                                          child: Text(
                                            brands[index],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  3.8, 8, 5, 8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.tertiarySystemFill,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9)),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 3,
                                    child: Icon(
                                      CupertinoIcons.search,
                                      size: 20,
                                      color: kGreenPrimary,
                                    ),
                                  ),
                                  Positioned(
                                    left: 37,
                                    child: Text(
                                      _brandController.text == ''
                                          ? 'Brand or Generic'
                                          : _brandController.text,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: _brandController.text == ''
                                            ? CupertinoColors.systemGrey
                                            : CupertinoColors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: InkWell(
                            onTap: () {
                              String drugName = _brandController.text;
                              if (drugName.contains('(Brand)')) {
                                drugName = drugName.replaceAll(' (Brand)', '');
                              } else if (drugName.contains('(Generic)')) {
                                drugName =
                                    drugName.replaceAll(' (Generic)', '');
                              }

                              for (int i = 0; i < forms.length; i++) {
                                if (forms[i][0] == drugName) {
                                  List<String> tempForm = forms[i];
                                  tempForm = tempForm.sublist(1);
                                  if (tempForm.length == 1) {
                                    _formController.text = tempForm[0];
                                  }
                                  _formScrollController.dispose();
                                  _formScrollController =
                                      FixedExtentScrollController(
                                          initialItem: formsIndex);

                                  _showDialog(
                                    CupertinoPicker(
                                      itemExtent: 40,
                                      scrollController: _formScrollController,
                                      // This is called when selected item is changed.
                                      onSelectedItemChanged:
                                          (int selectedItem) {
                                        formsIndex = selectedItem;

                                        BlocProvider.of<DrugSelectionBloc>(
                                                context)
                                            .add(
                                          UpdateForm(
                                            brand: _brandController.text,
                                            form: tempForm[selectedItem],
                                            dosage: dosage,
                                            quantity: quantity,
                                            drugStructure: state.drugStructure,
                                          ),
                                        );
                                      },
                                      children: List<Widget>.generate(
                                        tempForm.length,
                                        (int index) {
                                          return Container(
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                tempForm[index],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  3.8, 8, 5, 8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.tertiarySystemFill,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9)),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 3,
                                    child: Icon(
                                      CupertinoIcons.search,
                                      size: 20,
                                      color: kGreenPrimary,
                                    ),
                                  ),
                                  Positioned(
                                    left: 37,
                                    child: Text(
                                      _formController.text == ''
                                          ? 'Form'
                                          : _formController.text,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: _formController.text == ''
                                            ? CupertinoColors.systemGrey
                                            : CupertinoColors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: InkWell(
                            onTap: () {
                              String drugName = _brandController.text;
                              if (drugName.contains('(Brand)')) {
                                drugName = drugName.replaceAll(' (Brand)', '');
                              } else if (drugName.contains('(Generic)')) {
                                drugName =
                                    drugName.replaceAll(' (Generic)', '');
                              }

                              for (int i = 0; i < dosage.length; i++) {
                                for (int j = 0; j < dosage[i].length; j++) {
                                  if (dosage[i][j][0] == drugName) {
                                    if (dosage[i][j][1] ==
                                        _formController.text) {
                                      List<String> tempDosage = dosage[i][j];
                                      tempDosage = tempDosage.sublist(2);
                                      if (tempDosage.length == 1) {
                                        _dosageController.text = tempDosage[0];
                                      }
                                      _dosageScrollController.dispose();
                                      _dosageScrollController =
                                          FixedExtentScrollController(
                                              initialItem: dosageIndex);

                                      _showDialog(
                                        CupertinoPicker(
                                          itemExtent: 40,
                                          scrollController:
                                              _dosageScrollController,
                                          // This is called when selected item is changed.
                                          onSelectedItemChanged:
                                              (int selectedItem) {
                                            dosageIndex = selectedItem;

                                            BlocProvider.of<DrugSelectionBloc>(
                                                    context)
                                                .add(
                                              UpdateDosage(
                                                brand: _brandController.text,
                                                form: _formController.text,
                                                dosage:
                                                    tempDosage[selectedItem],
                                                quantity: quantity,
                                                drugStructure:
                                                    state.drugStructure,
                                              ),
                                            );
                                          },
                                          children: List<Widget>.generate(
                                            tempDosage.length,
                                            (int index) {
                                              return Container(
                                                height: 50,
                                                child: Center(
                                                  child: Text(
                                                    tempDosage[index],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  3.8, 8, 5, 8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.tertiarySystemFill,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9)),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 3,
                                    child: Icon(
                                      CupertinoIcons.search,
                                      size: 20,
                                      color: kGreenPrimary,
                                    ),
                                  ),
                                  Positioned(
                                    left: 37,
                                    child: Text(
                                      _dosageController.text == ''
                                          ? 'Dosage'
                                          : _dosageController.text,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: _dosageController.text == ''
                                            ? CupertinoColors.systemGrey
                                            : CupertinoColors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: InkWell(
                            onTap: () {
                              String drugName = _brandController.text;
                              if (drugName.contains('(Brand)')) {
                                drugName = drugName.replaceAll(' (Brand)', '');
                              } else if (drugName.contains('(Generic)')) {
                                drugName =
                                    drugName.replaceAll(' (Generic)', '');
                              }

                              for (int i = 0; i < quantity.length; i++) {
                                for (int j = 0; j < quantity[i].length; j++) {
                                  for (int k = 0;
                                      k < quantity[i][j].length;
                                      k++) {
                                    for (int l = 0;
                                        l < quantity[i][j][k].length;
                                        l++) {
                                      if (quantity[i][j][k][l] == drugName) {
                                        if (quantity[i][j][k][l + 1] ==
                                            _formController.text) {
                                          if (quantity[i][j][k][l + 2] ==
                                              _dosageController.text) {
                                            List<String> tempQuantity =
                                                quantity[i][j][k];
                                            tempQuantity =
                                                tempQuantity.sublist(3);
                                            if (tempQuantity.length == 1) {
                                              _quantityController.text =
                                                  tempQuantity[0];
                                            }
                                            _quantityScrollController.dispose();
                                            _quantityScrollController =
                                                FixedExtentScrollController(
                                                    initialItem: quantityIndex);

                                            _showDialog(
                                              CupertinoPicker(
                                                itemExtent: 40,
                                                scrollController:
                                                    _quantityScrollController,
                                                // This is called when selected item is changed.
                                                onSelectedItemChanged:
                                                    (int selectedItem) {
                                                  quantityIndex = selectedItem;

                                                  BlocProvider.of<
                                                              DrugSelectionBloc>(
                                                          context)
                                                      .add(
                                                    UpdateQuantity(
                                                      brand:
                                                          _brandController.text,
                                                      form:
                                                          _formController.text,
                                                      dosage: _dosageController
                                                          .text,
                                                      quantity: tempQuantity[
                                                          selectedItem],
                                                      drugStructure:
                                                          state.drugStructure,
                                                    ),
                                                  );
                                                },
                                                children: List<Widget>.generate(
                                                  tempQuantity.length,
                                                  (int index) {
                                                    return Container(
                                                      height: 50,
                                                      child: Center(
                                                        child: Text(
                                                          tempQuantity[index],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            },
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  3.8, 8, 5, 8),
                              decoration: BoxDecoration(
                                color: CupertinoColors.tertiarySystemFill,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9)),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    left: 3,
                                    child: Icon(
                                      CupertinoIcons.search,
                                      size: 20,
                                      color: kGreenPrimary,
                                    ),
                                  ),
                                  Positioned(
                                    left: 37,
                                    child: Text(
                                      _quantityController.text == ''
                                          ? 'Quantity'
                                          : _quantityController.text,
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: _quantityController.text == ''
                                            ? CupertinoColors.systemGrey
                                            : CupertinoColors.black,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 40.0,
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_zipCodeController.text != '' &&
                                  _brandController.text != '' &&
                                  _formController.text != '' &&
                                  _dosageController.text != '' &&
                                  _quantityController.text != '') {
                                String ndc = '';
                                String drugName = _brandController.text;
                                if (drugName.contains('(Brand)')) {
                                  drugName =
                                      drugName.replaceAll(' (Brand)', '');
                                } else if (drugName.contains('(Generic)')) {
                                  drugName =
                                      drugName.replaceAll(' (Generic)', '');
                                }
                                int numberOfBrands =
                                    state.drugStructure.value!.length;
                                for (int i = 0; i < numberOfBrands; i++) {
                                  if (state.drugStructure.value![i].key! ==
                                      drugName) {
                                    int numberOfForms = state
                                        .drugStructure.value![i].value!.length;
                                    for (int j = 0; j < numberOfForms; j++) {
                                      if (state.drugStructure.value![i]
                                              .value![j].key! ==
                                          _formController.text) {
                                        int numberOfDosage = state.drugStructure
                                            .value![i].value![j].value!.length;
                                        for (int k = 0;
                                            k < numberOfDosage;
                                            k++) {
                                          if (state.drugStructure.value![i]
                                                  .value![j].value![k].key! ==
                                              _dosageController.text) {
                                            ndc = state
                                                .drugStructure
                                                .value![i]
                                                .value![j]
                                                .value![k]
                                                .value![0]
                                                .value!
                                                .ndc!;
                                            break;
                                          }
                                        }
                                      }
                                    }
                                  }
                                }

                                if (ndc != '') {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setString(
                                      'zipcode', _zipCodeController.text);

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PricesScreen(
                                        drugName: drugName,
                                        ndc: ndc,
                                        zipCode: _zipCodeController.text,
                                        quantity: _quantityController.text,
                                        form: _formController.text,
                                        dosage: _dosageController.text,
                                      ),
                                    ),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'All fields are required',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                kGreenPrimary,
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Text(
                                'Compare Prices',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is DrugSelectionError) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 60.0,
                  right: 60.0,
                ),
                child: Center(
                  child: Text(
                    state.error,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            } else {
              return Container();
            }
          },
        ),
      ),
    );
  }

  Future<String> _getZipCodeFromGeolocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Location services are not enabled don't continue
        // accessing the position and request users of the
        // App to enable the location services.
        return Future.error('Location services are disabled.');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, next time you could try
          // requesting permissions again (this is also where
          // Android's shouldShowRequestPermissionRationale
          // returned true. According to Android guidelines
          // your App should show an explanatory UI now.
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Permissions are denied forever, handle appropriately.
        return Future.error(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      Placemark place = placemarks[0];

      if (place.postalCode == '') {
        Fluttertoast.showToast(
          msg: '  Please enter postal code manually.  ',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      print(position);

      return place.postalCode!;
    } on Exception catch (e) {
      throw e;
    }
  }
}
