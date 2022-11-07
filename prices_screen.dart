import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lowermyrx/bloc/pricing_bloc.dart';
import 'package:lowermyrx/repos/tiered_pricing_repo.dart';
import 'package:lowermyrx/screens/payment_screen.dart';

import '../models/tiered_pricing_model.dart';

class PricesScreen extends StatelessWidget {
  final String drugName;
  final String ndc;
  final String zipCode;
  final String quantity;
  final String form;
  final String dosage;

  const PricesScreen({
    Key? key,
    required this.drugName,
    required this.ndc,
    required this.zipCode,
    required this.quantity,
    required this.form,
    required this.dosage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TieredPricingRepository _tieredPricingRepository =
        TieredPricingRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(drugName),
        centerTitle: true,
      ),
      body: BlocProvider(
        create: (context) => PricingBloc(
          _tieredPricingRepository,
        )..add(
            GetTieredPricing(
              ndc: ndc,
              zipCode: zipCode,
              quantity: quantity,
            ),
          ),
        child: BlocBuilder<PricingBloc, PricingState>(
          builder: (context, state) {
            if (state is PricingLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is PricingLoaded) {
              return ListView.builder(
                itemCount: state.tieredPricing.value!.pharmacyPricings!.length,
                physics: BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: 20,
                ),
                itemBuilder: (context, index) {
                  Pharmacy pharmacy = state
                      .tieredPricing.value!.pharmacyPricings![index].pharmacy!;

                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 20.0,
                      right: 20,
                      top: 30.0,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              drugName: drugName,
                              zipCode: zipCode,
                              form: form,
                              dosage: dosage,
                              quantity: quantity,
                              tieredPricing: state.tieredPricing,
                              i: index,
                              update: false,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          left: 20.0,
                          right: 20,
                          top: 20.0,
                          bottom: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.3),
                              offset: Offset(0.1, 0.1),
                              blurRadius: 0.6,
                              spreadRadius: 0.2,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                pharmacy.logoUrl == null
                                    ? Container(
                                        width: 100,
                                        height: 20,
                                        child: Text(
                                          '${pharmacy.name}',
                                        ),
                                      )
                                    : SvgPicture.network(
                                        pharmacy.logoUrl!,
                                        width: 100,
                                        height: 20,
                                      ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    pharmacy.distance!.toStringAsFixed(2) +
                                        ' mi.',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '\$${state.tieredPricing.value!.pharmacyPricings![index].prices![0].price}',
                              style: TextStyle(
                                fontSize: 22.0,
                                color: Colors.pink,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (state is PricingError) {
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
}
