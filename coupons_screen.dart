import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lowermyrx/bloc/coupon_bloc.dart';
import 'package:lowermyrx/constants.dart';
import 'package:lowermyrx/screens/payment_screen.dart';
import 'package:shimmer/shimmer.dart';

class CouponScreen extends StatelessWidget {
  const CouponScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Saved Coupons'),
      ),
      body: BlocProvider(
        create: (context) => CouponBloc()
          ..add(
            LoadDatabase(),
          ),
        child: BlocConsumer<CouponBloc, CouponState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is CouponLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is CouponLoaded) {
              return RefreshIndicator(
                onRefresh: () {
                  BlocProvider.of<CouponBloc>(context).add(ScrollToRefresh());
                  Completer<void> completer = Completer<void>();
                  return completer.future;
                },
                child: ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: state.coupons.length,
                  padding: const EdgeInsets.only(
                    bottom: 20,
                  ),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        left: 28.0,
                        right: 28.0,
                        top: 30.0,
                      ),
                      child: Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1,
                            color: kGreenPrimary,
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              10,
                            ),
                          ),
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  drugName: state.coupons[index].drugName,
                                  zipCode: state.coupons[index].zipCode,
                                  form: state.coupons[index].form,
                                  dosage: state.coupons[index].dosage,
                                  quantity: state.coupons[index].quantity,
                                  tieredPricing:
                                      state.coupons[index].tieredPricing,
                                  i: state.coupons[index].i,
                                  update: true,
                                  id: state.coupons[index].id,
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Positioned(
                                top: 6,
                                right: 10,
                                child: PopupMenuButton(
                                  onSelected: (value) {
                                    BlocProvider.of<CouponBloc>(context).add(
                                      DeleteCoupon(
                                        id: state.coupons[index].id!,
                                      ),
                                    );
                                  },
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry>[
                                    const PopupMenuItem<String>(
                                      value: 'Remove',
                                      child: Text('Remove'),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 20,
                                child: Container(
                                  width: 270,
                                  child: Text(
                                    state.coupons[index].drugName,
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Raleway',
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 50,
                                child: Text(
                                  '${state.coupons[index].dosage}, ${state.coupons[index].quantity} ${state.coupons[index].form}',
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'Raleway',
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Positioned(
                                bottom: 60,
                                child: Container(
                                  width: 100,
                                  height: 30,
                                  child: state
                                              .coupons[index]
                                              .tieredPricing
                                              .value!
                                              .pharmacyPricings![
                                                  state.coupons[index].i]
                                              .pharmacy!
                                              .logoUrl ==
                                          null
                                      ? Shimmer.fromColors(
                                          baseColor: Colors.grey.shade200,
                                          highlightColor: Colors.grey.shade300,
                                          child: Container(
                                            color: Colors.grey.shade100,
                                          ),
                                        )
                                      : SvgPicture.network(
                                          state
                                              .coupons[index]
                                              .tieredPricing
                                              .value!
                                              .pharmacyPricings![
                                                  state.coupons[index].i]
                                              .pharmacy!
                                              .logoUrl!,
                                          height: 30,
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      new String.fromCharCodes(
                                          new Runes('\u0024')),
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Raleway",
                                      ),
                                    ),
                                    Text(
                                      '${state.coupons[index].tieredPricing.value!.pharmacyPricings![state.coupons[index].i].prices![0].price}',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: "Raleway",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            } else if (state is CouponError) {
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
