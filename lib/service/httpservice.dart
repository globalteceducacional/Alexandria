import 'dart:convert';

import 'package:elearn/consttants.dart';
import 'package:elearn/model/Profile.dart';
import 'package:elearn/model/allcategory.dart';
import 'package:elearn/model/categoryid.dart';
import 'package:elearn/model/exploreauthor.dart';
import 'package:elearn/model/explorelatest.dart';
import 'package:elearn/model/getsinglecategorybyid.dart';
import 'package:elearn/model/homecategory.dart';
import 'package:elearn/model/loginmodal.dart';
import 'package:elearn/model/singlebookbyid.dart';
import 'package:elearn/model/userregister.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/exploreallbook.dart';
import '../screens/bottom_navigation.dart';

class HttpService {
  static Future<UserLogin?> getUserLogin(context,
      {required String email, required String password}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      var response = await http.get(Uri.parse(
          "$apiLink/user_login_api.php?email=$email&password=$password&type=Normal&auth_id=''"));
      if (response.statusCode == 200) {
        final data = userLoginFromJson(response.body);
        if (data.ebookApp[0].success == "1") {
          sharedPreferences.setString("userId", data.ebookApp[0].userId);
          sharedPreferences.setString("type", "Normal");
          showToast(msg: '$email ${data.ebookApp[0].msg}');
          inAsyncCall.value = false;
          getUserId();
          Get.offAll(() => HomeScreen());
        } else {
          showToast(msg: data.ebookApp[0].msg);
          inAsyncCall.value = false;
        }
        return data;
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      inAsyncCall.value = false;
      print('Request failed with status:$e');
      showToast(msg: 'Email Not Exist !!!');
      return null;
    }
  }

  static Future<UserRegister?> getUserRegister(
    context, {
    required String email,
    required String password,
    required String name,
    required String number,
    required String type,
  }) async {
    try {
      var response = await http.get(
        Uri.parse(
          "$apiLink/user_register_api.php?name=$name&email=$email&password=$password&phone=$number&type=$type",
        ),
      );
      if (response.statusCode == 200) {
        final data = userRegisterFromJson(response.body);
        if (data.ebookApp[0].success == "1") {
          Get.back();
          showToast(msg: '$email ${data.ebookApp[0].msg}');
          inAsyncCall.value = false;
        } else {
          showToast(msg: data.ebookApp[0].msg);
          inAsyncCall.value = false;
        }
        return data;
      } else {
        inAsyncCall.value = false;
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      inAsyncCall.value = false;
      print('Request failed with status:$e');
      return null;
    }
  }

  Future<ProfileModel?> getUserProfile() async {
    try {
      var response =
          await http.get(Uri.parse('$apiLink/user_profile_api.php?id=$userId'));
      if (response.statusCode == 200) {
        return profileModelFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      print('Request failed with status:$e');
      return null;
    }
  }

  Future<AllCategory?> getAllCategory() async {
    try {
      var response =
          await http.get(Uri.parse('$apiLink/api.php?method_name=cat_list'));
      if (response.statusCode == 200) {
        return allCategoryFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      print('Request failed with status:$e');
      return null;
    }
  }

  Future<GetSingleCategoryById?> getSingleCategoryByCatId(
      {required catId}) async {
    try {
      var response = await http
          .get(Uri.parse('$apiLink/api.php?method_name=cat_id&cat_id=$catId'));
      if (response.statusCode == 200) {
        return getSingleCategoryByIdFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e, t) {
      print('Request failed with status:$e $t');
      return null;
    }
  }

  Future<CategoryId?> getCatId() async {
    try {
      var response = await http
          .get(Uri.parse('$apiLink/api.php?method_name=home_section'));
      if (response.statusCode == 200) {
        return categoryIdFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      print('Request failed with status:$e');
      return null;
    }
  }

  Future<CategoryById?> getCategoryById({required bookId}) async {
    try {
      var response = await http.get(Uri.parse(
          '$apiLink/api.php?method_name=home_section_id&homesection_id=$bookId&page=1'));
      if (response.statusCode == 200) {
        return categoryByIdFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e) {
      print('Request failed with status:$e');
      return null;
    }
  }

  Future<SingleBookById?> getSingleBookById({required bookId}) async {
    try {
      var response = await http.get(
          Uri.parse('$apiLink/api.php?method_name=book_id&book_id=$bookId'));
      if (response.statusCode == 200) {
        return singleBookByIdFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e, t) {
      print('Request failed with status:$e');
      print('Request failed with status:$t');
      return null;
    }
  }

  submitRating({required double rating, required String bookid}) async {
    var response = await http.get(Uri.parse(
        "$apiLink/api_rating.php?book_id=$bookid&user_id=$userId&rate=$rating"));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      showToast(msg: data["EBOOK_APP"][0]['MSG']);
    }
  }

  Future<CategoryById?> getSingleViewBook({required id}) async {
    try {
      var response = await http.get(Uri.parse(
          '$apiLink/api.php?method_name=home_section_id&homesection_id=$id&page=1'));
      if (response.statusCode == 200) {
        return categoryByIdFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e, t) {
      print('Request failed with status:$e');
      print('Request failed with status:$t');
      return null;
    }
  }

  Future<ExploreLatestBook?> getExploreLatestBook() async {
    try {
      var response =
          await http.get(Uri.parse('$apiLink/api.php?method_name=latest'));
      if (response.statusCode == 200) {
        return exploreLatestBookFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e, t) {
      print('Request failed with status:$e');
      print('Request failed with status:$t');
      return null;
    }
  }

  Future<ExploreAuthor?> getExploreAuthor() async {
    try {
      var response =
          await http.get(Uri.parse('$apiLink/api.php?method_name=author_list'));
      if (response.statusCode == 200) {
        return exploreAuthorFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e, t) {
      print('Request failed with status:$e');
      print('Request failed with status:$t');
      return null;
    }
  }

  Future<ExploreAllBook?> getExploreAllBooks() async {
    try {
      var response =
          await http.get(Uri.parse('$apiLink/api.php?method_name=allbook'));
      if (response.statusCode == 200) {
        return exploreAllBookFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e, t) {
      print('Request failed with status:$e');
      print('Request failed with status:$t');
      return null;
    }
  }

  Future<GetSingleCategoryById?> getSingleAuthorById({required authId}) async {
    try {
      var response = await http.get(Uri.parse(
          '$apiLink/api.php?method_name=author_id&author_id=$authId'));
      if (response.statusCode == 200) {
        return getSingleCategoryByIdFromJson(response.body);
      } else {
        throw 'Request failed with status: ${response.statusCode}';
      }
    } catch (e, t) {
      print('Request failed with status:$e');
      print('Request failed with status:$t');
      return null;
    }
  }
}
