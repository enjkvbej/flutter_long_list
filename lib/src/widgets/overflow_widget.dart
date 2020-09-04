import 'package:flutter/material.dart';

class GlowNotificationWidget extends StatelessWidget {
  final bool showGlowLeading;
  final bool showGlowTrailing;
  final Widget child;  
  const GlowNotificationWidget(
    {this.child, this.showGlowLeading = false, this.showGlowTrailing = false});
 
  @override
  Widget build(BuildContext context) {
    return NotificationListener<OverscrollIndicatorNotification>(
        onNotification: _handleGlowNotification, child: child);
  }

  bool _handleGlowNotification(OverscrollIndicatorNotification notification) {
    if ((notification.leading && !showGlowLeading) ||
        (!notification.leading && !showGlowTrailing)) {
          print('OverscrollIndicatorNotification');
      notification.disallowGlow();
      return true;
    }
    return false;
  }
}