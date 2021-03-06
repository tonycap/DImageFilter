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


+ (Mat)addMatFirst:(Mat)src1 second:(Mat)src2;

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

@interface GLImageOperate (BaseOparetion)

+ (Mat)binaryzation:(Mat)srcMat;

+ (Mat)binaryzation:(Mat)srcMat threshValue:(int)value;

@end

/**
 *  边缘检测处理
 */
@interface GLImageOperate (edgeDetection)

+ (Mat)prewitt:(Mat)src;

+ (Mat)roberts:(Mat)src;

+ (Mat)distanceTransform:(Mat)srcMat;
@end