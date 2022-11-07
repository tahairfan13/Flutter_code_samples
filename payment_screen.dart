import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lowermyrx/bloc/payment_bloc.dart';
import 'package:lowermyrx/constants.dart';
import 'package:lowermyrx/database/coupon_database.dart';
import 'package:lowermyrx/models/coupon_model.dart';
import 'package:lowermyrx/models/tiered_pricing_model.dart';
import 'package:lowermyrx/repos/maps_repo.dart';
import 'package:lowermyrx/screens/email_screen.dart';

class PaymentScreen extends StatelessWidget {
  final String drugName;
  final String zipCode;
  final String form;
  final String dosage;
  final String quantity;
  final TieredPricing tieredPricing;
  final int i;
  final bool update;
  final int? id;

  const PaymentScreen({
    Key? key,
    required this.drugName,
    required this.zipCode,
    required this.form,
    required this.dosage,
    required this.quantity,
    required this.tieredPricing,
    required this.i,
    required this.update,
    this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MapsRepository _mapsRepository = MapsRepository();

    List<PharmacyPricing> allPharmacies =
        tieredPricing.value!.pharmacyPricings!;
    List<PharmacyPricing> samePharmacies = [];

    for (int j = 0; j < allPharmacies.length; j++) {
      if (tieredPricing.value!.pharmacyPricings![i].pharmacy!.name! ==
          tieredPricing.value!.pharmacyPricings![j].pharmacy!.name!) {
        samePharmacies.add(tieredPricing.value!.pharmacyPricings![j]);
      }
    }

    samePharmacies
        .sort((a, b) => a.pharmacy!.distance!.compareTo(b.pharmacy!.distance!));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        centerTitle: true,
        title: Column(
          children: [
            Text(drugName),
            Text('$quantity $form, $dosage'),
          ],
        ),
      ),
      body: BlocProvider(
        create: (context) => PaymentBloc(
          _mapsRepository,
        ),
        child: BlocConsumer<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is MapsLoaded) {
              _launchURL(Uri.parse(state.url));
            }
          },
          builder: (context, state) {
            if (state is PaymentInitial) {
              return SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 30.0,
                    left: 20.0,
                    right: 20.0,
                    bottom: 20.0,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          tieredPricing.value!.pharmacyPricings![i].pharmacy!
                                      .logoUrl !=
                                  null
                              ? SvgPicture.network(
                                  tieredPricing.value!.pharmacyPricings![i]
                                      .pharmacy!.logoUrl!,
                                  width: 150,
                                )
                              : Container(
                                  width: 150,
                                  height: 40,
                                  child: Center(
                                    child: Text(
                                      '${tieredPricing.value!.pharmacyPricings![i].pharmacy!.name}',
                                    ),
                                  ),
                                ),
                          Text(
                            '\$${tieredPricing.value!.pharmacyPricings![i].prices![0].price!}',
                            style: TextStyle(
                              fontSize: 22.0,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 18.0,
                          bottom: 18.0,
                        ),
                        child: Text(
                          'Show this coupon upon checkout at ${tieredPricing.value!.pharmacyPricings![i].pharmacy!.name!}.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 15.0,
                          right: 15.0,
                        ),
                        child: Image.asset(
                          'assets/app_coupon.jpeg',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 12.0,
                          bottom: 5.0,
                        ),
                        child: Text(
                          'This is not insurance. Prescription coupon only.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.normal,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                      Text(
                        'Prices subject to change.',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.normal,
                          fontSize: 12.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 20.0,
                          bottom: 5.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(kGreenPrimary),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Fluttertoast.showToast(
                                  msg: '  Coupon Saved  ',
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.BOTTOM,
                                  timeInSecForIosWeb: 1,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );

                                if (update == true) {
                                  CouponDatabase.instance.update(
                                    Coupon(
                                      id: id,
                                      drugName: drugName,
                                      zipCode: zipCode,
                                      form: form,
                                      dosage: dosage,
                                      quantity: quantity,
                                      time: DateTime.now(),
                                      tieredPricing: tieredPricing,
                                      i: i,
                                    ),
                                  );
                                } else if (update == false) {
                                  CouponDatabase.instance.create(
                                    Coupon(
                                      id: null,
                                      drugName: drugName,
                                      zipCode: zipCode,
                                      form: form,
                                      dosage: dosage,
                                      quantity: quantity,
                                      time: DateTime.now(),
                                      tieredPricing: tieredPricing,
                                      i: i,
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Save Coupon',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(kGreenPrimary),
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmailScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  'Email',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(kGreenPrimary),
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (await Permission.storage.request().isGranted) {
                              _saveNetworkImage();
                              Fluttertoast.showToast(
                                msg: '  Image Saved to Gallery  ',
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                timeInSecForIosWeb: 1,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              'Save To Gallery',
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 30.0,
                          bottom: 10.0,
                        ),
                        child: Text(
                          'Nearby Pharmacies',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 25.0,
                          ),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: samePharmacies.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          String pharmacyName = samePharmacies[index]
                              .pharmacy!
                              .name!
                              .replaceAll(RegExp(' +'), '%20');
                          String pharmacyAddress = samePharmacies[index]
                              .pharmacy!
                              .address!
                              .address1!
                              .replaceAll(RegExp(' +'), '%20');

                          return Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  width: 2.0,
                                  color: kGreenPrimary,
                                ),
                              ),
                            ),
                            child: TextButton(
                              style: ButtonStyle(),
                              onPressed: () {
                                BlocProvider.of<PaymentBloc>(context).add(
                                  LoadMaps(
                                    pharmacyName: pharmacyName,
                                    pharmacyAddress: pharmacyAddress,
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        samePharmacies[index].pharmacy!.name!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        samePharmacies[index]
                                            .pharmacy!
                                            .address!
                                            .address1!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                      Text(
                                        samePharmacies[index]
                                            .pharmacy!
                                            .address!
                                            .city!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${samePharmacies[index].pharmacy!.distance!.toStringAsFixed(1)} mi.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is PaymentError) {
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

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  void _saveNetworkImage() async {
    final File f1 = await getImageFileFromAssets('coupon.jpg');
    ImageGallerySaver.saveFile(f1.path);
  }

  void _launchURL(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
  }
}
