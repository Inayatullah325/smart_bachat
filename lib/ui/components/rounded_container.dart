import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class RoundedContainer extends StatelessWidget {
  final Color? containerColor;
  final IconData? containerIcon;
  final String? containerText;
  final int? containerValue;

  RoundedContainer({
    required this.containerColor,
    required this.containerIcon,
    required this.containerText,
    required this.containerValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.w),
      width: MediaQuery.of(context).size.width * 0.45,
      constraints: BoxConstraints(minHeight: 10.h),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(1.5.h),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(containerIcon, size: 3.h, color: Colors.white70),
              SizedBox(width: 2.w),
              Flexible(
                child: Text(
                  containerText!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Rs $containerValue',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
