//
//  GLFilterImageVC.m
//  DImageFilter
//
//  Created by tony on 6/19/16.
//  Copyright © 2016 sjtu. All rights reserved.
//

#import "GLFilterImageVC.h"

#import "UIView+Frame.h"
#import "GLSliderView.h"

#import "Masonry.h"
#import "GLMenuView.h"
#import "UIImage+OpenCV.h"
#import "Toast+UIView.h"
#import "GLConventViewController.h"
#import "BaseOperatorVC.h"

#import "STAlbumManager.h"

#import "Macro.h"
#import "MBProgressHUD.h"

@interface GLFilterImageVC ()<GLMenuItemDelegate,CXSliderDelegate>

@property (nonatomic, assign) OperateType type;
@property (nonatomic, assign) int changeValue;
@property (nonatomic, strong) NSString *sliderTitle;

@property (weak, nonatomic) IBOutlet UIView *headerView;

@property (nonatomic, strong) UIImageView *filterImageView;

@property (nonatomic, strong) GLMenuView *menuView;
@property (nonatomic, strong) GLSliderView *sliderView;

@end

@implementation GLFilterImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
//    {"title":, "subMenu":{"title":,"imageName":,@"operateType":}}
    self.title = @"图片处理";
    self.headerView.hidden = TRUE;
    _menuView = [[GLMenuView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 100, ScreenWidth, 100) menuArr:[self menuDataSourceInit]];
    _menuView.delegate = self;
    [self.view addSubview:self.menuView];
    
    CGFloat width = ScreenWidth - 2*Padding20;
    _filterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(Padding20, Padding20, width, width)];
    _filterImageView.center = CGPointMake(ScreenWidth/2, ScreenHeight/2);
    _filterImageView.image = self.originImg;
    [self.view addSubview:_filterImageView];
    _filterImageView.userInteractionEnabled = TRUE;
    
    self.navigationController.navigationBarHidden = TRUE;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenuView)];
    [self.view addGestureRecognizer:recognizer];
    
    [self.menuView itemSelectAtIndex:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dismissView:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)transformEvent:(id)sender {
    BaseOperatorVC *VC = [[BaseOperatorVC alloc] init];
    VC.originImg = self.originImg;
    [self.navigationController pushViewController:VC animated:TRUE];
}

- (IBAction)savePhoto:(id)sender {
    [self saveImageToAlbum];
    [self.view makeToast:@"保存图片成功"];
}

- (IBAction)recognizerBtnEvent:(id)sender {
    GLConventViewController *VC = [[GLConventViewController alloc] init];
    [self.navigationController pushViewController:VC animated:TRUE];
}

#pragma mark -- GestureRecognizer Event
- (void)showMenuView{
    if (self.menuView.hidden) {
        self.menuView.hidden = FALSE;
        self.sliderView.hidden = TRUE;
    }
}

- (void)showHUD{
    [MBProgressHUD showHUDAddedTo:self.view animated:TRUE];
}

- (void)hiddentHUD{
    [MBProgressHUD hideHUDForView:self.view animated:TRUE];
}

- (void)saveImageToAlbum{
    [[STAlbumManager sharedManager] saveImage:self.filterImageView.image toAlbum:@"图像处理" completionHandler:^(UIImage *image, NSError *error) {
        if(error){
            if (error.code == ALAssetsLibraryAccessUserDeniedError) {
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"请在iPhone的\"设置-隐私-照片\"选项中,允许该应用访问你的照片。" message:nil delegate:nil  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }else if(error.code == ALAssetsLibraryWriteDiskSpaceError){
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"存储空间不足,请在iPhone的\"设置-通用-用量\"选项中设置。" message:nil delegate:nil  cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alertView show];
            }
        }else {
            [self.view makeToast:@"图片保存成功"];
        }
        
    }];
}

#pragma mark -- CXSliderDelegate
-(void)cxSliderValueChanged:(CGFloat)value{
    self.sliderView.titleStr = [NSString stringWithFormat:@"%@%.f",self.sliderTitle, value];
    if (self.changeValue != (int)value) {
        self.changeValue = (int)value;
        [self imageFilterWithType:self.type];
    }
}

- (void)showSlideWitTitle:(NSString *)title{
    self.sliderTitle = title ;
    
    if (!self.sliderView) {
        self.sliderView = [[GLSliderView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 100, ScreenWidth, 80)];
        self.sliderView.delegate = self;
        [self.view addSubview:self.sliderView];
    }

    self.sliderView.titleStr = [NSString stringWithFormat:@"%@ 0",self.sliderTitle];
    self.menuView.hidden = TRUE;
    self.sliderView.hidden = FALSE;
    [self.sliderView.sliderView setValueWithValue:0];
}

- (int)changeValueWithDefault:(int)defaultValue{
    int value = (self.changeValue == 0 ? defaultValue : self.changeValue);
    
    return value;
}

#pragma mark ---GLMenuItemDelegate
- (void)menuItemSelect:(id)menuInfo{
    if ([menuInfo isKindOfClass:[NSDictionary class]]) {
        NSDictionary *value = (NSDictionary *)menuInfo;
        NSInteger operateType = [[value objectForKey:@"operateType"] integerValue];
        [self imageFilterWithType:operateType];
    }
}

- (void)imageFilterWithType:(NSInteger)type{
    self.type = (OperateType)type;
    
    [self showHUD];
    
    NSString *typeStr = [@(type) stringValue];
    if ([typeStr hasPrefix:@"100"]) {
        [self grayOperate:type];
        [self hiddentHUD];
        return;
    }
    
    if ([typeStr hasPrefix:@"200"]) {
        [self binaryOperate:type];
        [self hiddentHUD];
        return;
    }
    
    if ([typeStr hasPrefix:@"210"]) {
        [self binaryMorphologyOperate:type];
        [self hiddentHUD];
        return;
    }
    
    if ([typeStr hasPrefix:@"300"]) {
        [self morphologyOperate:type];
        [self hiddentHUD];
        return;
    }
    if ([typeStr hasPrefix:@"400"]) {
        [self edgeInfoOperate:type];
        [self hiddentHUD];
        return;
    }
    if ([typeStr hasPrefix:@"500"]) {
        [self smoothingOperate:type];
        [self hiddentHUD];
        return;
    }
    
    if ([typeStr hasPrefix:@"600"]) {
        [self skeletonOperate:type];
        [self hiddentHUD];
        return;
    }
//    未捕获设置原图，灰度图中放置二值化及均衡化处理
    self.filterImageView.image = self.originImg;
}

- (void)grayOperate:(NSInteger)type{
    UIImage *dstImage;
    switch (type) {
        case GrayFilter:
        {
            dstImage = [self.originImg grayImage];
        }
            break;
        case GrayHist:
            dstImage = [self.originImg grayHistImg];
            break;
        case  GrayEqual:
            dstImage = [self.originImg equalHistImg];
            break;
        case GrayHistEqual:
            dstImage = [self.originImg histogramEqualization];
            break;
        default:
            break;
    }
    
    self.filterImageView.image = dstImage;
}

- (void)binaryOperate:(NSInteger)type{
    UIImage *dstImage;
    switch (type) {
        case BinaryDetech:
            dstImage = [self.originImg binaryzationWithWithDetech];
            break;
        case BinaryOTSU:
            dstImage = [self.originImg binaryzation];
            break;
        case BinaryMaxEntropy:
            dstImage = [self.originImg binaryzationWithMaxEntropy];
            break;
        case BinaryGlobal:
            dstImage = [self.originImg binaryzationWithWithGlobalThrehold];
            break;
            
        case BinaryCustom:
            {
                [self showSlideWitTitle:@"阈值大小："];
                self.sliderView.maxValue = 255;
                dstImage = [self.originImg binaryzationWithThresh:[self changeValueWithDefault:125]];
            }
            break;
        default:
            break;
    }
    
    self.filterImageView.image = dstImage;
}

- (void)binaryMorphologyOperate:(NSInteger)type{
    UIImage *dstImage;
    
    [self showSlideWitTitle:@"内核算子大小："];
    self.sliderView.maxValue = 50;
    int value = [self changeValueWithDefault:2];
    switch (type) {
        case BinMorphologyErosion:
        {
            dstImage = [[self.originImg grayImage] erosionType:3 size:value];
        }
            break;
        case BinMorphologyDilate:
            dstImage = [[self.originImg grayImage] erosionType:3 size:value];
            break;
        case BinMorphologyOpen:
        {
            [self showSlideWitTitle:@"内核算子大小："];
            
            dstImage = [[self.originImg grayImage] morphologyWithOperation:3 elementSize:value];
        }
            
            break;
        case BinMorphologyClose:
        {
            [self showSlideWitTitle:@"内核算子大小："];
            dstImage = [[self.originImg grayImage] morphologyWithOperation:4 elementSize:value];
        }
            
            break;
            
        default:
            break;
    }
    
    self.filterImageView.image = dstImage;
}

- (void)morphologyOperate:(NSInteger)type{
    UIImage *dstImage;
    
    [self showSlideWitTitle:@"内核算子大小："];
    self.sliderView.maxValue = 30;
    int value = [self changeValueWithDefault:1];
    switch (type) {
        case MorphologyErosion:
        {
            self.sliderView.maxValue = 30;
            dstImage = [self.originImg erosionType:1 size:value];
        }
            break;
        case MorphologyDilate:
        {
            dstImage = [self.originImg dilationWithType:1 size:value];
        }
            break;
        case MorphologyOpen:
        case MorphologyClose:
        case MorphologyGradient:
        case MorphologyTopHat:
        case MorphologyBlackHat:
            {
                int operate = type%10 - 3;
                dstImage = [self.originImg morphologyWithOperation:operate elementSize:value];
            }
            break;
            
        default:
            break;
    }
    
    self.filterImageView.image = dstImage;
}

- (void)edgeInfoOperate:(NSInteger)type{
    UIImage *dstImage;
    switch (type) {
        case EdgeSobel:
        {
            [self showSlideWitTitle:@"Scale 值"];
            dstImage = [self.originImg sobelWithScale:[self changeValueWithDefault:3]];
        }
            break;
        case EdgeCanny:
        {
            [self showSlideWitTitle:@"阈值大小:"];
            dstImage = [self.originImg cannyWithThreshold:[self changeValueWithDefault:15]];
        }
            break;
        case EdgeLaplace:
        {
            [self showSlideWitTitle:@"内核算子大小："];
            dstImage = [self.originImg LaplaceWithSize:[self changeValueWithDefault:25]];
        }
            break;
        case EdgeScharr:
        {
            [self showSlideWitTitle:@"Scale值"];
            dstImage = [self.originImg scharrWithScale:[self changeValueWithDefault:10]];
        }
            break;
        case EdgeRoberts:
            dstImage = [self.originImg robertsEdge];
            break;
        case EdgePrewitt:
            dstImage = [self.originImg prewittEdge];
            break;
            
        default:
            break;
    }
    self.filterImageView.image = dstImage;
}

- (void)smoothingOperate:(NSInteger)type{
    UIImage *dstImage;
    
    [self showSlideWitTitle:@"内核算子大小："];
    self.sliderView.maxValue = 100;
    int value = [self changeValueWithDefault:3];
    
    switch (type) {
        case SmoothBoxBlur:
        {
            dstImage = [self.originImg boxBlurFilterWithSize:value];
        }
            break;
        case SmoothBlur:
            dstImage = [self.originImg blureFilterWithSize:value];
            break;
        case SmoothGussianBlur:
            
            dstImage = [self.originImg gaussianBlurFilterWithSize:value];
            break;
        case SmoothMedianBlur:
            dstImage = [self.originImg medianFilterWithkSize:value];
            break;
        case SmoothBilatelBlur:
            dstImage = [self.originImg bilateralFilterWithSie:value];
            break;
            
        default:
            break;
    }
    self.filterImageView.image = dstImage;
}

- (void)skeletonOperate:(NSInteger)type{
    UIImage *dstImage;
    switch (type) {
        case SkeletonDistanceTransform:
        {
            dstImage = [self.originImg distanceTransform];
        }
            break;
        case SkeletonHilditch:
            dstImage = [self.originImg skeletonByHilditch];
            break;
        case SkeletonRosenfeld:
            dstImage = [self.originImg skeletonByRosenfeld];
            break;
        case SkeletonMorph:
            dstImage = [self.originImg skeletonByMorph];
            break;
            
        default:
            break;
    }
    self.filterImageView.image = dstImage;
    
}

#pragma mark --
- (NSMutableArray *)menuDataSourceInit{
    NSDictionary *edgeMenu = @{@"title" : @"边缘检测",
                               @"subMenu" :@[
                                       @{@"title" : @"sobel算子",@"imageName":@"pegman_01",@"operateType":@(EdgeSobel)},
                                       @{@"title" : @"canny算子",@"imageName":@"pegman_02",@"operateType":@(EdgeCanny)},
                                       @{@"title" : @"Laplace算子",@"imageName":@"pegman_03",@"operateType":@(EdgeLaplace)},
                                       @{@"title" : @"scharr算子",@"imageName":@"pegman_04",@"operateType":@(EdgeScharr)},
                                       @{@"title" : @"Roberts算子",@"imageName":@"pegman_05",@"operateType":@(EdgeRoberts)},
                                       @{@"title" : @"Prewitt算子",@"imageName":@"pegman_06",@"operateType":@(EdgePrewitt)}
                                       ]};
    NSDictionary *greyMenu =  @{@"title" : @"灰度化",
                                @"subMenu" : @[
                                        @{@"title" : @"灰度图",@"imageName":@"pegman_07",@"operateType":@(GrayFilter)},
                                        @{@"title" : @"直方图",@"imageName":@"pegman_08",@"operateType":@(GrayHist)},
                                        @{@"title" : @"均衡化",@"imageName":@"pegman_09",@"operateType":@(GrayEqual)},
                                        @{@"title" : @"直方图均衡化",@"imageName":@"pegman_10",@"operateType":@(GrayHistEqual)}
                                        ]};
    NSDictionary *binMenu = @{@"title" : @"二值化",
                              @"subMenu" :@[
                                      @{@"title" : @"迭代法",@"imageName":@"pegman_11",@"operateType":@(BinaryDetech)},
                                      @{@"title" : @"OTSU法",@"imageName":@"pegman_12",@"operateType":@(BinaryOTSU)},
                                      @{@"title" : @"熵阈值",@"imageName":@"pegman_13",@"operateType":@(BinaryMaxEntropy)},
                                      @{@"title" : @"全局阈值",@"imageName":@"pegman_14",@"operateType":@(BinaryGlobal)},
                                      @{@"title" : @"自定义阈值",@"imageName":@"pegman_15",@"operateType":@(BinaryCustom)}
                                      ]};
    NSDictionary *binMorpholoMenu = @{@"title" : @"二值形态学操作",
                              @"subMenu" :@[
                                      @{@"title" : @"腐蚀",@"imageName":@"pegman_16",@"operateType":@(BinMorphologyErosion)},
                                      @{@"title" : @"膨胀",@"imageName":@"pegman_01",@"operateType":@(BinMorphologyDilate)},
                                      @{@"title" : @"开运算",@"imageName":@"pegman_02",@"operateType":@(BinMorphologyOpen)},
                                      @{@"title" : @"闭运算",@"imageName":@"pegman_03",@"operateType":@(BinMorphologyClose)}
                                      ]};
    NSDictionary *morphologyMenu = @{@"title" : @"形态学",
                                     @"subMenu" :@[
                                             @{@"title" : @"腐蚀",@"imageName":@"pegman_04",@"operateType":@(MorphologyErosion)},
                                             @{@"title" : @"膨胀",@"imageName":@"pegman_05",@"operateType":@(MorphologyDilate)},
                                             @{@"title" : @"开运算",@"imageName":@"pegman_06",@"operateType":@(MorphologyOpen)},
                                             @{@"title" : @"闭运算",@"imageName":@"pegman_07",@"operateType":@(MorphologyClose)},
                                             @{@"title" : @"形态学梯度",@"imageName":@"pegman_08",@"operateType":@(MorphologyGradient)},
                                             @{@"title" : @"顶帽",@"imageName":@"pegman_09",@"operateType":@(MorphologyTopHat)},
                                             @{@"title" : @"黑帽",@"imageName":@"pegman_10",@"operateType":@(MorphologyBlackHat)}
                                             ]};
    NSDictionary *smoothMenu = @{@"title" : @"滤波",
                                 @"subMenu" :@[
                                         @{@"title" : @"方框滤波",@"imageName":@"pegman_11",@"operateType":@(SmoothBoxBlur)},
                                         @{@"title" : @"均值滤波",@"imageName":@"pegman_12",@"operateType":@(SmoothBlur)},
                                         @{@"title" : @"高斯滤波",@"imageName":@"pegman_13",@"operateType":@(SmoothGussianBlur)},
                                         @{@"title" : @"中值滤波",@"imageName":@"pegman_14",@"operateType":@(SmoothMedianBlur)},
                                         @{@"title" : @"双边滤波",@"imageName":@"pegman_15",@"operateType":@(SmoothBilatelBlur)}
                                         ]};
    NSDictionary *skeletonMenu = @{@"title" : @"骨架",
                                   @"subMenu" :@[
                                           @{@"title" : @"距离转换",@"imageName":@"pegman_16",@"operateType":@(SkeletonDistanceTransform)},
                                           @{@"title" : @"hilditch细化",@"imageName":@"pegman_15",@"operateType":@(SkeletonHilditch)},
                                           @{@"title" : @"Rosenfeld细化",@"imageName":@"pegman_14",@"operateType":@(SkeletonRosenfeld)},
                                           @{@"title" : @"形态学骨架",@"imageName":@"pegman_13",@"operateType":@(SkeletonMorph)}
                                           ]};

    
    NSMutableArray *menuArr = [@[greyMenu, binMenu, morphologyMenu,edgeMenu,smoothMenu, skeletonMenu] mutableCopy];
    
    return menuArr;
}

@end
