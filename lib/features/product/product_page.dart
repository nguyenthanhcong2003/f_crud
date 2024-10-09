import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../auth/auth_service.dart';
import '../account/login_page.dart';
import 'create_product_page.dart';
import 'edit_product_page.dart';

class ProductPage extends StatefulWidget {
  final String? displayName;

  const ProductPage({super.key, this.displayName});

  @override
  _ProductPageSate createState() => _ProductPageSate();
}

class _ProductPageSate extends State<ProductPage> {
  List<Map<String, dynamic>> productsList = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

  void fetchProducts() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('product').get();
    setState(() {
      productsList = querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    });
  }

  void deleteProduct(String productId) async {
    try {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('product').doc(productId);

      DocumentSnapshot documentSnapshot = await documentReference.get();
      if (documentSnapshot.exists) {
        String imageUrl = documentSnapshot['productImage'];
        if (imageUrl.isNotEmpty) {
          Reference imageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await imageRef.delete();
        }
      }

      await documentReference.delete();
      print('$productId deleted');
      setState(() {
        productsList
            .removeWhere((product) => product["productId"] == productId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xóa sản phẩm thành công'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.displayName != null
                        ? 'Xin chào Admin ${widget.displayName}'
                        : 'Xin chào Admin',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    auth.signout();
                    goToLogin(context);
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Danh sách sản phẩm',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold),
            ),
            Container(
              height: 3,
              color: const Color(0xFF36D7FF),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: productsList.length,
                itemBuilder: (BuildContext context, int index) {
                  var product = productsList[index];
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Colors.black, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.0),
                              child: product["productImage"] != null
                                  ? Image.network(
                                      product["productImage"],
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (BuildContext context,
                                          Object exception,
                                          StackTrace? stackTrace) {
                                        return Container(
                                          height: 50,
                                          width: 50,
                                          color: Colors.grey,
                                          child: const Icon(Icons.error,
                                              color: Colors.red),
                                        );
                                      },
                                    )
                                  : Container(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    product["productName"] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Text(
                                    product["productType"] ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  product["productPrice"]?.toString() ?? '',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 50,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.green,
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditProductPage(
                                                product: product,
                                                onUpdate: (updatedProduct) {
                                                  setState(() {
                                                    productsList[index] =
                                                        updatedProduct;
                                                  });
                                                },
                                              )),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () =>
                                      deleteProduct(product["productId"]),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateProductPage(onCreate: (newProduct) {
                setState(() {
                  productsList.add(newProduct);
                });
              }),
            ),
          );
        },
        backgroundColor: const Color(0xFF960FFF),
        foregroundColor: const Color(0xFFFFFFFF),
        child: const Icon(Icons.add),
      ),
    );
  }
}
