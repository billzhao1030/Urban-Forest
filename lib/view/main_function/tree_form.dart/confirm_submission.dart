import 'package:flutter/cupertino.dart';
import 'package:urban_forest/reusable_widgets/reusable_methods.dart';

class ConfirmSubmit extends StatefulWidget {
  const ConfirmSubmit({ Key? key }) : super(key: key);

  @override
  State<ConfirmSubmit> createState() => _ConfirmSubmitState();
}

class _ConfirmSubmitState extends State<ConfirmSubmit> {
  @override
  Widget build(BuildContext context) {
    return backgroundDecoration(
      context, 
      Container()
    );
  }
}