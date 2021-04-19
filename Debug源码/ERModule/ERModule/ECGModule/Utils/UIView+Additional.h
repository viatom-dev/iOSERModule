//
//  UIView+Additional.h
//  hipal
//
//  Created by demo on 13-7-18.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIView (Additional)
-(UIImage*)captureView;
-(UIImage *)captureViewWithSize:(CGSize )capSize;

//矩形
-(void)drawRectangle:(CGRect)rect;
//圆角矩形
-(void)drawRectangle:(CGRect)rect withRadius:(float)radius;
//画多边形
//pointArray = @[[NSValue valueWithCGPoint:CGPointMake(200, 400)]];
-(void)drawPolygon:(NSArray *)pointArray;
-(void)drawPolygon:(NSArray *)pointArray withEdgeColor:(UIColor*)edgeColor withFillColor:(UIColor*)fillColor;
//圆形
-(void)drawCircleWithCenter:(CGPoint)center
                     radius:(float)radius;
//曲线
-(void)drawCurveFrom:(CGPoint)startPoint
                  to:(CGPoint)endPoint
       controlPoint1:(CGPoint)controlPoint1
       controlPoint2:(CGPoint)controlPoint2;

//弧线
-(void)drawArcFromCenter:(CGPoint)center
                  radius:(float)radius
              startAngle:(float)startAngle
                endAngle:(float)endAngle
               clockwise:(BOOL)clockwise;
//扇形
-(void)drawSectorFromCenter:(CGPoint)center
                     radius:(float)radius
                 startAngle:(float)startAngle
                   endAngle:(float)endAngle
                  clockwise:(BOOL)clockwise;

//直线
-(void)drawLineFrom:(CGPoint)startPoint
                 to:(CGPoint)endPoint;

/*
 折线，连续直线
 pointArray = @[[NSValue valueWithCGPoint:CGPointMake(200, 400)]];
 */
-(void)drawLines:(NSArray *)pointArray;



-(CGMutablePathRef)pathwithFrame:(CGRect)frame withRadius:(float)radius;


@end
