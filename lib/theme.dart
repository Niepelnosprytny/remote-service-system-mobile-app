import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AppTheme {
  static ThemeData lightTheme() {
    return ThemeData(
      scaffoldBackgroundColor: const Color(0xFFD9D9D9),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF373F51),
        toolbarHeight: 10.h,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          color: const Color(0xFFF4F4F4),
        ),
        iconTheme: IconThemeData(
          size: 25.sp,
          color: const Color(0xFFF4F4F4),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.5.sp,
            color: const Color(0xFF000000),
          ),
          borderRadius: BorderRadius.circular(5.sp),
        ),
      ),
      listTileTheme: ListTileThemeData(
        titleAlignment: ListTileTitleAlignment.center,
        contentPadding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
        textColor: const Color(0xFF000000),
        titleTextStyle: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.bold,
        ),
        subtitleTextStyle: TextStyle(
          fontSize: 12.5.sp,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFDAA49A),
          padding: EdgeInsets.fromLTRB(12.5.w, 1.5.h, 12.5.w, 1.5.h),
          fixedSize: Size(80.w, 10.h),
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 0.25.sp,
              color: const Color(0xFF000000),
            ),
            borderRadius: BorderRadius.circular(5.sp),
          ),
          textStyle: TextStyle(
            fontSize: 15.sp,
            color: const Color(0xFF000000),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(15.sp),
        labelStyle: TextStyle(
          fontSize: 15.sp,
          color: const Color(0xFF000000),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintStyle: TextStyle(
          fontSize: 12.5.sp,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 5.sp,
            color: const Color(0xFF000000),
          ),
          borderRadius: BorderRadius.circular(5.sp),
        ),
      ),
    );
  }

  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith();
  }
}