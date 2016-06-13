//
//  GLImageOperate.h
//  DImageFilter
//
//  Created by tony on 6/9/16.
//  Copyright © 2016 sjtu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "opencv2/opencv.hpp"

using namespace cv;

@interface GLImageOperate : NSObject

/**
 *  改变突变对比度与亮度
 *
 *  @param srcMat 原图Mat
 *  @param alpha  对比度
 *  @param beta   亮度 1~100之间
 */
+ (Mat)adjustMat:(Mat)srcMat contrast:(float)alpha Bright:(float)beta;


+ (Mat)addMatFirst:(Mat)src1 second:(Mat)src2;

/**
 *  图像大小变换
 *
 *  @param srcMat 原图矩阵
 *  @param type   图像插值类型，0——最近邻插值， 1——双线性插值， 2——立方插值
 */
+ (Mat)cvReSize:(Mat)srcMat interType:(int)type;

/**
 *  矩阵平移， 原图像不变
 *
 *  @param srcMat 原矩阵
 *  @param dx     X方向平移
 *  @param dy     Y方向平移
 */
+ (Mat)translateTransform:(Mat)srcMat X:(int)dx Y:(int)dy;

/**
 *  平移后图像的大小变化
 *
 *  @param srcMat 原矩阵
 *  @param dx     X方向平移
 *  @param dy     Y方向平移
 */
+ (Mat)translateSizeChangeTransform:(Mat)srcMat X:(int)dx Y:(int)dy;

/**
* 水平镜像, 在水平镜像变换时，遍历了整个图像，然后根据映射关系对每个像素都做了处理。
* 实际上，水平镜像变换就是将图像坐标的列换到右边，右边的列换到左边，是可以以列为单位做变换的。同样垂直镜像变换也如此，可以以行为单位进行变换。
*
*  @param srcMat 原图像矩阵
*
*  @return 处理后的矩阵
*/
+ (Mat)mirrorHTransmit:(Mat)srcMat;

/**
 *  垂直镜像处理
 */
+ (Mat)mirrorVTransmit:(Mat)srcMat;

//图像旋转变换（原尺寸）
+ (IplImage *)rotateImageWithSrcImage:(IplImage *)srcImg degree:(int)degree;

#pragma mark ——————————  阈值算法  ——————————
/**
 *  大津法取阈值
 *
 *  @param pImageData 图像数据
 *  @param nWidth     图像宽度
 *  @param nHeight    图像高度
 *  @param nWidthStep 图像行大小
 *
 *  @return 阈值
 */
int  OTSU(unsigned char* pGrayImg , int iWidth , int iHeight);

@end

@interface GLImageOperate (edgeDetection)


void roberts(IplImage *src,IplImage *dst);

void sobel(IplImage *src,IplImage *dst);

void prewitt(IplImage *src,IplImage *dst);

void kirsch(IplImage *src,IplImage *dst);

@end
