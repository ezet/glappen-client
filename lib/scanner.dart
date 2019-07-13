import 'package:flutter/cupertino.dart';
import 'package:qr_mobile_vision/qr_camera.dart';

class Scanner extends StatelessWidget {
  Scanner({Key key}) : super(key: key);

  var done = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SizedBox(
        width: 300,
        height: 300,
        child: QrCamera(qrCodeCallback: (code) {
          if (done == false) {
            done = true;
            Navigator.pop(context, code);
          }
        }));
  }
}
