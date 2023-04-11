import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/product_model.dart';

class DataBaseController extends GetxController {
  RxInt countDown = 30.obs;
  Random random = Random();
  RxInt randomNumber = 0.obs;
  RxBool isAddToCart = false.obs;

  RxList<Product> productFetchData = <Product>[].obs;
  RxList<Product> productDecorededList = <Product>[].obs;

  Database? dbs;

  String tableName = "product";
  String column1_ID = "id";
  String column2_name = "name";
  String column3_image = "image";
  String column4_quantity = "quantity";

  RxList<String> images = <String>[].obs;

  Future<void> loadString({required String path}) async {
    String productData = await rootBundle.loadString(path);
    productDecorededList.value = productFromJson(productData);
  }

  Future<Database?> init() async {
    String path = await getDatabasesPath();

    String dataBasePath = join(path, "product.db");

    dbs = await openDatabase(
      dataBasePath,
      version: 1,
      onCreate: (Database database, version) async {
        String query =
            "CREATE TABLE IF NOT EXISTS $tableName($column1_ID INTEGER PRIMARY KEY AUTOINCREMENT, $column2_name TEXT, $column3_image TEXT, $column4_quantity INTEGER);";
        await database.execute(query);
      },
    );
    String query =
        "CREATE TABLE IF NOT EXISTS $tableName($column1_ID INTEGER PRIMARY KEY AUTOINCREMENT, $column2_name TEXT, $column3_image TEXT, $column4_quantity INTEGER);";
    dbs!.execute(query);
    return dbs;
  }

  Future insertBulkRecord() async {
    deleteTable();
    await init();

    for (Product product in productDecorededList) {
      String image = await getImagesBytes(url: product.image ?? "") ?? "";
      images.add(image);
    }

    for (var i = 0; i < productDecorededList.length; i++) {
      Product product = productDecorededList[i];
      String sql =
          "INSERT INTO $tableName VALUES(null,'${product.name}', '${images[i]}', ${product.quantity})";
      await dbs!.rawInsert(sql);
    }
  }

  Future deleteTable() async {
    await init();
    String sql = "DROP TABLE $tableName";
    await dbs!.execute(sql);
  }

  Future<void> fetchData() async {
    dbs = await init();
    String sql = "SELECT *FROM $tableName";

    List<Map<String, dynamic>> data = await dbs!.rawQuery(sql);
    productFetchData.value = productFromJson(jsonEncode(data));
    randomNumber.value = random.nextInt(15);
    countDownTimer();
  }

  Future<void> recoverData() async {
    String sql = "SELECT *FROM $tableName";

    List<Map<String, dynamic>> data = await dbs!.rawQuery(sql);
    productFetchData.value = productFromJson(jsonEncode(data));
  }

  Future<String?> getImagesBytes({required String url}) async {
    http.Response response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Uint8List bytes = response.bodyBytes;
      return base64Encode(bytes);
    }
    return null;
  }

  Future<void> addToCart({required Product product}) async {
    await init();

    int? quantity;
    if (product.quantity! > 0) {
      quantity = product.quantity! - 1;
    }

    String query =
        "UPDATE  $tableName SET $column4_quantity = ${quantity ?? 0} WHERE $column1_ID = ${product.id};";
    dbs!.rawUpdate(query);

    String selectQuery =
        "SELECT *FROM $tableName WHERE $column1_ID = ${product.id};";
    List<Map<String, dynamic>> data = await dbs!.rawQuery(selectQuery);
    productFetchData[product.id! - 1] = Product.fromJson(data[0]);
  }

  Future<void> stockManage() async {
    dbs = await init();

    int id = productFetchData[randomNumber.value].id!;

    String query =
        "UPDATE  $tableName SET $column4_quantity = 0 WHERE $column1_ID = $id;";
    dbs!.rawUpdate(query);

    String selectQuery = "SELECT *FROM $tableName WHERE $column1_ID = $id;";
    List<Map<String, dynamic>> data = await dbs!.rawQuery(selectQuery);
    productFetchData[randomNumber.value] = Product.fromJson(data[0]);
  }

  void countDownTimer() async {
    Future.delayed(
      const Duration(seconds: 1),
      () async {
        countDown.value--;
        if (countDown.value == 20 && isAddToCart.isFalse) {
          await stockManage();
        }
        if (countDown.value == 0) {
          await fetchData();
          countDown(30);
          isAddToCart(false);
        } else {
          countDownTimer();
        }
      },
    );
  }
}
