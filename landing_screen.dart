import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lowermyrx/bloc/home_bloc.dart';
import 'package:lowermyrx/constants.dart';
import 'package:lowermyrx/repos/token_repo.dart';
import 'package:lowermyrx/screens/search_screen.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  TextEditingController myController = new TextEditingController();
  TextEditingController _searchController = TextEditingController();
  final TokenRepository _tokenRepository = TokenRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => HomeBloc(_tokenRepository)
          ..add(
            GetToken(),
          ),
        child: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is HomeLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is HomeLoaded) {
              return RefreshIndicator(
                onRefresh: () {
                  BlocProvider.of<HomeBloc>(context).add(ScrollToRefresh());
                  Completer<void> completer = Completer<void>();
                  return completer.future;
                },
                child: GestureDetector(
                  onTap: () {
                    FocusScopeNode currentFocus = FocusScope.of(context);

                    if (!currentFocus.hasPrimaryFocus) {
                      currentFocus.unfocus();
                    }
                  },
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          color: kGreenPrimary,
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Image(
                            image: AssetImage(
                              'assets/splash_new.png',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
                          child: Container(
                            child: Text(
                              "Don't overpay for your prescriptions.",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 8, 30, 0),
                          child: Container(
                            child: Text(
                              "Compare discounted prices for your medication at pharmacies near you.",
                              style: TextStyle(
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.only(
                        //     top: 30.0,
                        //     left: 30,
                        //     right: 30,
                        //   ),
                        //   child: InkWell(
                        //     onTap: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) => SearchScreen(
                        //             query: '',
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //     child: CupertinoSearchTextField(
                        //enabled: false,
                        // autocorrect: false,
                        //controller: _searchController,
                        // onSubmitted: (value) {
                        //   if (value.isNotEmpty) {
                        //     Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) => SearchScreen(
                        //           query: value,
                        //         ),
                        //       ),
                        //     );
                        //   }
                        // },
                        //       padding: const EdgeInsets.only(
                        //         top: 15,
                        //         bottom: 15,
                        //         left: 15,
                        //         right: 15,
                        //       ),
                        //       itemColor: kGreenPrimary,
                        //       placeholder: 'Search for a drug',
                        //     ),
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 30.0,
                            left: 30,
                            right: 30,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SearchScreen(
                                    query: '',
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: CupertinoColors.tertiarySystemFill,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, top: 14, right: 5, bottom: 14),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.search,
                                      color: kGreenPrimary,
                                      size: 20.0,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Text(
                                        'Search for a drug',
                                        style: TextStyle(
                                          color: CupertinoColors.secondaryLabel,
                                          fontSize: 16.5,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30, 20.0, 30, 0),
                          child: ElevatedButton(
                            onPressed: () {
                              if (_searchController.text != '') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SearchScreen(
                                      query: _searchController.text,
                                    ),
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
                                'Compare Drug Prices',
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
            } else if (state is HomeError) {
              return RefreshIndicator(
                onRefresh: () {
                  BlocProvider.of<HomeBloc>(context).add(ScrollToRefresh());
                  Completer<void> completer = Completer<void>();
                  return completer.future;
                },
                child: Padding(
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
