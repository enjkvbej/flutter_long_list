
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../store/long_list_provider.dart';

class LongListError<T extends Clone<T>> extends StatelessWidget {
  final String id;
  LongListError({@required this.id, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '服务器出小差了，请重试',
          style: TextStyle(
            color: Colors.black.withOpacity(0.5),
            fontWeight: FontWeight.bold,
            fontSize: 13
          )
        ),
        SizedBox(height: 120),
        MaterialButton(
          onPressed: () {
            context.read<LongListProvider<T>>().refresh(id);
          },
          minWidth: 272,
          height: 120,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(60),
            ),
          ),
          color: Theme.of(context).primaryColor,
          child: Text(
            '重试',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ),
      ]
    );
  }
}