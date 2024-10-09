import 'package:dntgk/features/product/product_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(Map<String, dynamic>) onUpdate;

  const EditProductPage(
      {super.key, required this.product, required this.onUpdate});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController productNameController;
  late TextEditingController productTypeController;
  late TextEditingController productPriceController;
  File? productImage;
  final ImagePicker _picker = ImagePicker();

  late String productName;
  late String productType;
  late double productPrice;

  @override
  void initState() {
    super.initState();
    productNameController =
        TextEditingController(text: widget.product['productName']);
    productTypeController =
        TextEditingController(text: widget.product['productType']);
    productPriceController =
        TextEditingController(text: widget.product['productPrice'].toString());

    productName = widget.product['productName'];
    productType = widget.product['productType'];
    productPrice = widget.product['productPrice'];
  }

  @override
  void dispose() {
    productNameController.dispose();
    productTypeController.dispose();
    productPriceController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        productImage = File(pickedFile.path);
      });
    }
  }

  Future<String> uploadImage(File image) async {
    String fileName = widget.product['productId'];
    Reference storageReference =
        FirebaseStorage.instance.ref().child('imageproduct/$fileName');

    SettableMetadata metadata = SettableMetadata(
      contentType: 'image/jpeg',
    );

    UploadTask uploadTask = storageReference.putFile(image, metadata);
    await uploadTask.whenComplete(() => null);
    return await storageReference.getDownloadURL();
  }

  Future<void> updateData() async {
    if (_formKey.currentState!.validate()) {
      // Form is valid, proceed with the update
      print("Update button clicked");
      try {
        String? imageUrl;
        if (productImage != null) {
          // Delete the old image from Firebase Storage
          String oldImageUrl = widget.product['productImage'];
          if (oldImageUrl.isNotEmpty) {
            Reference oldImageRef =
                FirebaseStorage.instance.refFromURL(oldImageUrl);
            await oldImageRef.delete();
          }

          // Upload the new image
          imageUrl = await uploadImage(productImage!);
        } else {
          imageUrl = widget.product['productImage'];
        }

        DocumentReference documentReference = FirebaseFirestore.instance
            .collection('product')
            .doc(widget.product['productId']);

        Map<String, dynamic> updatedProduct = {
          "productId": widget.product['productId'],
          "productName": productName,
          "productType": productType,
          "productPrice": productPrice,
          "productImage": imageUrl
        };

        await documentReference.update(updatedProduct);
        widget.onUpdate(updatedProduct);

        // Hiển thị SnackBar khi cập nhật sản phẩm thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật sản phẩm thành công!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        print('Error updating product: $e');
      }
    } else {
      // Form is not valid, show validation errors
      print('Validation failed');
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
                  child: Text('Cập nhật sản phẩm',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: TextFormField(
                    controller: productNameController,
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
                    controller: productTypeController,
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
                    controller: productPriceController,
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
                            pickImage(); // Gọi hàm chọn ảnh
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
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              )
                            : widget.product['productImage'] != null
                                ? Image.network(
                                    widget.product['productImage'],
                                    height: 100,
                                    width: 100,
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
                            updateData(); // Gọi hàm tạo sản phẩm
                          },
                          child: const Text('Cập nhật sản phẩm',
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
