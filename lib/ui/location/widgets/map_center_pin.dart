import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_icons.dart';

/// The fixed pin overlay shown at the exact center of the map on the Pick
/// Location screen. The map pans underneath it; the pin itself never moves.
class MapCenterPin extends StatelessWidget {
  const MapCenterPin({super.key});

  static const double _width = 56;
  static const double _height = 63;

  @override
  Widget build(BuildContext context) {
    // The asset's own shadow ellipse sits near the bottom of the image —
    // shift it up so that point (not the image's bounding-box center) lands
    // on the map's true center. Approximate; nudge once the asset is final.
    return Transform.translate(
      offset: const Offset(0, -_height * 0.3),
      child: Image.asset(
        AppIcons.mapPinConfirmIcon,
        width: _width,
        height: _height,
      ),
    );
  }
}
