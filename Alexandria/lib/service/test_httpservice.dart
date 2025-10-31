import 'package:elearn/service/httpservice.dart';

void testGetSingleBookById() async {
  int testBookId = 1; // Replace with a valid book ID for testing
  var response = await HttpService().getSingleBookById(bookId: testBookId);

  if (response != null && response.ebookApp.isNotEmpty) {
    print('Book Cover Image URL: ${response.ebookApp[0].bookCoverImg}');
  } else {
    print('No data found for the given book ID.');
  }
}

void main() {
  testGetSingleBookById();
}
