import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dntgk/features/product/product_page.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateProductPage extends StatefulWidget {
  final Function(Map<String, dynamic>) onCreate;

  const CreateProductPage({super.key, required this.onCreate});

  @override
  _CreateProductPageState createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final _formKey = GlobalKey<FormState>();
  String productName = '', productType = '';
  double productPrice = 0.0;
  File? productImage;
  final ImagePicker _picker = ImagePicker();
  String productId = '';
  List<Map<String, dynamic>> productsList = [];

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        productImage = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = const Uuid().v4();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('imageproduct/$fileName');

    SettableMetadata metadata = SettableMetadata(
      cacheControl: 'public,max-age=300',
      contentType: 'image/jpeg',
    );

    UploadTask uploadTask = storageReference.putFile(image, metadata);
    await uploadTask.whenComplete(() => null);
    return await storageReference.getDownloadURL();
  }

  Future<void> createData() async {
    if (_formKey.currentState!.validate()) {
      print("Create button clicked");
      if (productImage != null) {
        try {
          print('Uploading image...');
          String imageUrl = await uploadImage(productImage!);
          print('Image uploaded: $imageUrl');

          var uuid = const Uuid();
          productId = uuid.v4();
          DocumentReference documentReference =
              FirebaseFirestore.instance.collection('product').doc(productId);
          Map<String, dynamic> product = {
            "productId": productId,
            "productName": productName,
            "productType": productType,
            "productPrice": productPrice,
            "productImage": imageUrl
          };

          await documentReference.set(product);
          print('$productName created');
          setState(() {
            productsList.add(product);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo sản phẩm thành công!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => ProductPage()),
            (Route<dynamic> route) => false,
          );
        } catch (e) {
          print('Error creating product: $e');
        }
      } else {
        print('No image selected');
      }
    } else {
      print('Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 100),
                  child: Text('Tạo sản phẩm',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tên sản phẩm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập tên sản phẩm';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        productName = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Loại sản phẩm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập loại sản phẩm';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        productType = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Giá sản phẩm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập giá sản phẩm';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        productPrice = double.parse(value);
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            elevation: 5.0,
                            backgroundColor: Colors.blue,
                          ),
                          onPressed: () {
                            pickImage();
                          },
                          child: const Text('Chọn ảnh',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        height: 100,
                        width: 100,
                        child: productImage != null
                            ? Image.file(
                                productImage!,
                                height: 50,
                                width: 50,
                                fit: BoxFit.cover,
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                            elevation: 8.0,
                            backgroundColor: Colors.green,
                          ),
                          onPressed: () {
                            createData(); // Gọi hàm tạo sản phẩm
                          },
                          child: const Text('Tạo sản phẩm',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProductPage()),
                              (Route<dynamic> route) => false,
                            );
                          },
                          child: const Text('Danh sách',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
