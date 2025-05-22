import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSkeleton extends StatelessWidget {
  const ShimmerSkeleton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: 80,
        width: MediaQuery.of(context).size.width*0.8,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          // borderRadius: borderRadius,
        ),
      ),
    );
  }
}
