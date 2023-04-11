import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/database_controller.dart';
import '../models/product_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DataBaseController dataBaseController = Get.find();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await dataBaseController.loadString(
          path: "assets/json/product_data.json");
      await dataBaseController.init();
      await dataBaseController.insertBulkRecord();
      await dataBaseController.fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Products", style: TextStyle(fontSize: 28),),
        centerTitle: true,
        backgroundColor: const Color(0xffB4E4FF),
      ),
      body: Obx(() =>
      (dataBaseController.productFetchData.value.isEmpty)
          ? const Center(
        child: CircularProgressIndicator(),
      )
              : Padding(
          padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.06, vertical: size.width * 0.05),
      child: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: dataBaseController.productFetchData.length,
                itemBuilder: (context, index) {
                  Product product =
                  dataBaseController.productFetchData[index];
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    clipBehavior: Clip.none,
                    decoration: BoxDecoration(
                      color: const Color(0xffB4E4FF),
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Container(
                          width: size.width * 0.9,
                          height: size.width * 0.5,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            // color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            width: size.width * 0.7,
                            height: size.width * 0.5,
                            decoration: const BoxDecoration(),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: MemoryImage(
                                    base64Decode(product.image!),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              margin: const EdgeInsets.only(left: 0),
                              child: Text(
                                "${product.name}",
                                style: const TextStyle(
                                    color: Colors.black, fontSize: 25,fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(left: 120),
                              child: Row(
                                children: [
                                  const Text("Quantity: ",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,fontWeight: FontWeight.w500)),
                                  Text(
                                    "${product.quantity}",
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (product.quantity != 0)
                              InkWell(
                                onTap: () {
                                  if (dataBaseController
                                      .randomNumber.value ==
                                      index &&
                                      dataBaseController.countDown.value >=
                                          20) {
                                    dataBaseController.isAddToCart(true);
                                  }

                                  dataBaseController.addToCart(
                                      product: product);
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(10)),
                                  child: const Text("Add To Cart",
                                      style:
                                      TextStyle(color: Colors.black,fontWeight: FontWeight.w600,fontSize: 22)),
                                ),
                              ),
                            const SizedBox(height: 10),
                            if (index ==
                                dataBaseController.randomNumber.value) ...[
                              Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Colors.white,
                                  ),
                                  width: 250,
                                  height:60,
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Out Of Stock",
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 20,fontWeight: FontWeight.w600,letterSpacing: 1),
                                      ),
                                      const SizedBox(width: 10),
                                      Obx(
                                            () =>
                                            Text(
                                              "${dataBaseController.countDown.value}",
                                              style: const TextStyle(
                                                  color: Colors.red, fontSize: 22),
                                            ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
          ),
        ],
      ),
    ),
      ),
    );
  }
}
