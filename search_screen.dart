import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:lowermyrx/bloc/search_bloc.dart';
import 'package:lowermyrx/constants.dart';
import 'package:lowermyrx/repos/search_repo.dart';
import 'package:lowermyrx/screens/drug_selection_screen.dart';

class SearchScreen extends StatelessWidget {
  final String query;

  const SearchScreen({
    Key? key,
    required this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SearchRepository _searchRepository = SearchRepository();
    TextEditingController _searchController = TextEditingController();

    return BlocProvider<SearchBloc>(
      create: (context) => SearchBloc(_searchRepository)
        ..add(
          GetQuery(
            query: query,
          ),
        ),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Search'),
        ),
        body: Column(
          children: [
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 30.0,
                    left: 30,
                    right: 30,
                  ),
                  child: CupertinoSearchTextField(
                    autofocus: true,
                    autocorrect: false,
                    controller: _searchController,
                    onChanged: (value) {
                      BlocProvider.of<SearchBloc>(context).add(
                        GetQuery(
                          query: value,
                        ),
                      );
                    },
                    onSubmitted: (value) {
                      BlocProvider.of<SearchBloc>(context).add(
                        GetQuery(
                          query: value,
                        ),
                      );
                    },
                    padding: const EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                      left: 15,
                      right: 15,
                    ),
                    itemColor: kGreenPrimary,
                    placeholder: 'Search for a drug',
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchLoading) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is SearchLoaded) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 10,
                        left: 30.0,
                        right: 30,
                      ),
                      child: ListView.builder(
                        physics: BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.searchQuery.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DrugSelectionScreen(
                                        displayName: state
                                            .searchQuery[index].displayName!,
                                        seoName:
                                            state.searchQuery[index].seoName!,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 60,
                                  width: double.infinity,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 10.0),
                                        child: Text(
                                          state.searchQuery[index].displayName!,
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(
                                thickness: 2,
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  } else if (state is SearchError) {
                    return Expanded(
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
          ],
        ),
      ),
    );
  }
}
