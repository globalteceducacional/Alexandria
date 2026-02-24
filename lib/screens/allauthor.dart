import 'package:elearn/generated/l10n.dart';
import 'package:elearn/model/exploreauthor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../consttants.dart';
import 'explore.dart';

class AllAuthors extends StatefulWidget {
  const AllAuthors({super.key, required this.bookAuthor});
  final ExploreAuthor? bookAuthor;

  @override
  State<AllAuthors> createState() => _AllAuthorsState();
}

class _AllAuthorsState extends State<AllAuthors> {
  final TextEditingController _searchController = TextEditingController();
  List<EbookApp> _filteredAuthors = [];

  @override
  void initState() {
    super.initState();
    _filteredAuthors = widget.bookAuthor!.ebookApp;
  }

  void _filterAuthors(String query) {
    setState(() {
      _filteredAuthors = widget.bookAuthor!.ebookApp
          .where((author) =>
              author.authorName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: comboBlackAndWhite(),
      appBar: AppBar(
        backgroundColor: comboBlackAndWhite(),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: comboWhiteAndBlack(),
        ),
        title: Text(S.of(context).explore_AUTHOR,
            style: TextStyle(
                color: comboWhiteAndBlack(), fontFamily: "Gilroy-Medium")),
        elevation: 0.0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25.r),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Pesquisar autores...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.search, color: Colors.black54),
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onChanged: _filterAuthors,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              physics: const ScrollPhysics(),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: _filteredAuthors.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.w,
                crossAxisCount: 2,
                childAspectRatio: 0.880,
              ),
              itemBuilder: (context, index) {
                return AuthorView(
                  authorName: _filteredAuthors[index].authorName,
                  authorImage: _filteredAuthors[index].authorImage,
                  authid: int.parse(_filteredAuthors[index].authorId),
                  authorDescription: _filteredAuthors[index].authorDescription,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
