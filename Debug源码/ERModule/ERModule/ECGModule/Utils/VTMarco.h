//
//  VTMarco.h
//  ERModule
//
//  Created by yangweichao on 2021/4/6.
//

#ifndef VTMarco_h
#define VTMarco_h

#define kScreenHeight [[UIScreen mainScreen] bounds].size.height
#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define ISIPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define ISIPHONEX (ISIPHONE && kScreenHeight >= 812.0)


#define point_per_mm 3.0    //  1mm对应的点数   (point)
#define seconds_leftToRight 7.8   //一行波形的秒数  (s)   旧的image报告为7  新的pdf报告改为7.8
#define thickLineW 1.0   //   粗线
#define thinLineW 0.5    //   细线
#define SEC_FIRSTROW 7.6
#define SEC_PER_ROW 7
#define H_PER_ROW   12 * 5 * point_per_mm  //每行高度
#define upper_limit 30 * point_per_mm //一行波形上限值为20毫米（3大格）   (单位:point)
#define lower_limit 10 * point_per_mm //一行波形下限值为20毫米（2大格）   (单位:point)

//常量
#define A4_width 210   //  (mm)
#define A4_height 297  //  (mm)
#define mm_per_mV 10  // 1毫伏=10mm
#define mm_per_second 25 //25mm/s

#define viapadding ((whole_width - wave_width) / 2)       //左右空白的宽度   (point)

//延伸
#define points_per_mV (mm_per_mV * point_per_mm)  //1mV对应的point点
#define wave_width ((mm_per_second * seconds_leftToRight) * point_per_mm)     //一行波形的宽度   (point)
#define whole_width (A4_width * point_per_mm)       //整屏的宽  (point)
#define whole_height (A4_height * point_per_mm)     //整屏的高  (point)
#define padding ((whole_width - wave_width) / 2)       //左右空白的宽度   (point)


#define ERDIR_AIReport_File         @"ER1AIReport"


#endif /* VTMarco_h */
