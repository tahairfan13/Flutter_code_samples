import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:path_provider/path_provider.dart';

import 'package:lowermyrx/constants.dart';

class EmailScreen extends StatelessWidget {
  const EmailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _nameController = TextEditingController();
    TextEditingController _emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 30.0,
          left: 30.0,
          right: 30.0,
        ),
        child: Column(
          children: [
            CupertinoSearchTextField(
              autocorrect: false,
              controller: _nameController,
              padding: const EdgeInsets.only(
                top: 15,
                bottom: 15,
                left: 15,
                right: 15,
              ),
              itemColor: kGreenPrimary,
              placeholder: 'Enter your name',
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                bottom: 30.0,
              ),
              child: CupertinoSearchTextField(
                autocorrect: false,
                controller: _emailController,
                padding: const EdgeInsets.only(
                  top: 15,
                  bottom: 15,
                  left: 15,
                  right: 15,
                ),
                itemColor: kGreenPrimary,
                placeholder: 'Enter your email',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trimRight() == '' &&
                    _nameController.text.trimRight() == '') {
                  Fluttertoast.showToast(
                    msg: '  All fields are required  ',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else if (_nameController.text.trimRight() == '' &&
                    _nameController.text.trimRight() != '') {
                  if (_nameController.text.trimRight() == '' &&
                      EmailValidator.validate(
                          _emailController.text.trimRight())) {
                    Fluttertoast.showToast(
                      msg: '  Enter a name  ',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: '  Enter a name and valid email  ',
                      toastLength: Toast.LENGTH_LONG,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                } else if (_nameController.text.trimRight() != '' &&
                    _nameController.text.trimRight() == '') {
                  Fluttertoast.showToast(
                    msg: '  Enter an email  ',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else if ((_nameController.text.trimRight() != '' &&
                    EmailValidator.validate(
                            _emailController.text.trimRight()) ==
                        false)) {
                  Fluttertoast.showToast(
                    msg: '  Enter a valid email  ',
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                } else if ((_nameController.text.trimRight() != '' &&
                    EmailValidator.validate(
                            _emailController.text.trimRight()) ==
                        true)) {
                  sendMail(_nameController.text, _emailController.text);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Email Sent',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      backgroundColor: Color(0xFF10BA07),
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
                  'Email',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  sendMail(String name, String email) async {
    String userEmailfrom = 'card@lowermyrx.com';
    String password = 'aPPs##123';
    final File coupon = await getImageFileFromAssets('lowermyrx350.jpg');
    // ignore: deprecated_member_use
    final smtpServer = gmail(userEmailfrom, password);
    final message = Message()
      ..from = Address(userEmailfrom, 'LowerMyRx')
      ..recipients.add(email)
      ..subject =
          'Your Requested LowerMyRx Prescription Discount Card  ${DateTime.now()}'
      ..text = 'Hello, please find your discount card below'
      ..html = "<p>Hi $name,</p>"
          "\n<p>Here's your active LowerMyRx Prescription Discount Card that you can use right away!</p>"
          "\n<p>Print as many as you want or save the card image to your device to use later. Show your LowerMyRx card to your pharmacist and a discount up to 80% will be applied instantly.</p>"
          "\n<p>Share your LowerMyRx card with friends, family, and anyone you know that would benefit. Help spread the word about our free program.</p>"
          "\n<p style='text-align:center';><span><img src='cid:presciption-coupon' alt='Prescription Discount Card' width='350' loading='lazy'></span></p>"
          "\n<p>The LowerMyRx Prescription Discount Card provides discounts on both brand name and generic drugs at over 35,000 pharmacies nationwide. Cardholders have saved up to 80% on prescription drug purchases at their current pharmacies. There are no enrollment forms, no age or income requirements, no waiting periods, no eligibility requirements, no exclusions, covers pre-existing conditions, no claim forms to file, no annual or lifetime limits. Use the LowerMyRx prescription discount card every time you go to the pharmacy. </p>"
          "\n<p>Since 2013, the LowerMyRx Prescription Discount Program has saved users millions on their prescription medications.</p>"
          "\n<hr><p style='text-align:center'><span style='font-size:10px'>This is a one time email sent by request from the LowerMyRx card request form. LowerMyRx is NOT insurance and is not a substitute for insurance. LowerMyRx is NOT a Medicare prescription drug plan and is not a substitute for a Medicare prescription drug plan. Discounts displayed are estimated and discounts may vary. Discounts are only available at participating pharmacies. Not available in Tennessee.</span></p>"
      ..attachments = [
        FileAttachment(coupon)
          ..location = Location.inline
          ..cid = '<presciption-coupon>'
      ];
    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent.');
      for (var p in e.problems) {
        print('Problem: ${p.code}: ${p.msg}');
      }
    }
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
}
