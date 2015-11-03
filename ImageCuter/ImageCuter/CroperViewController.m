//
//  CroperViewController.m
//  ImageCutter
//
//  Created by Lanseer on 15/11/2.
//  Copyright © 2015年 Lacar. All rights reserved.
//

#import "CroperViewController.h"

#define w [[UIScreen mainScreen] bounds].size.width
#define h [[UIScreen mainScreen] bounds].size.height
#define animateDuration  0.3f
#define cropCircleSize 100
#define statusBarHeight 20
@interface CroperViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UIScrollViewDelegate>{

    UIScrollView *_imageScrollView;//图片用scrollview容纳，方便缩放
    CALayer *_bgLayer;//蒙层
    CALayer *_cropZone;//圆形裁减区域
    UIImage *_image;//要裁减的图片数据
}


@end

@implementation CroperViewController



#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor=[UIColor whiteColor];
    _image=[[UIImage alloc] init];
    _image=[UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"localData"]];
    [self normalizedImage];
    
    //图片载体
    _imageScrollView=[[UIScrollView alloc] init];
    _imageScrollView.frame=CGRectMake(w/2-_image.size.width/2, h/2-_image.size.height/2, _image.size.width, _image.size.height);
    _imageScrollView.contentSize=CGSizeMake(_imageScrollView.frame.size.width, _imageScrollView.frame.size.height);
    _imageScrollView.showsHorizontalScrollIndicator=NO;
    _imageScrollView.showsVerticalScrollIndicator=NO;
    _imageScrollView.userInteractionEnabled=YES;
    _imageScrollView.scrollEnabled=NO;
    _imageScrollView.clipsToBounds=NO;
    _imageScrollView.minimumZoomScale=MAX(cropCircleSize/_image.size.width, cropCircleSize/_image.size.height);
    _imageScrollView.maximumZoomScale=_imageScrollView.minimumZoomScale*4;
    _imageScrollView.delegate=self;
    [self.view addSubview:_imageScrollView];
    
    //要裁减的图片
    UIImageView *cuttedImage=[[UIImageView alloc] init];
    cuttedImage.frame=CGRectMake(0, 0, _imageScrollView.frame.size.width, _imageScrollView.frame.size.height);
    cuttedImage.image=_image;
    cuttedImage.tag=101;
    [_imageScrollView addSubview:cuttedImage];
    
    _imageScrollView.zoomScale=MIN(w/_image.size.width, h/_image.size.height);
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    //蒙层
    _bgLayer=[[CALayer alloc] init];
    _bgLayer.frame=self.view.frame;
    _bgLayer.backgroundColor=[[UIColor blackColor] colorWithAlphaComponent:0.8f].CGColor;
    [self.view.layer addSublayer:_bgLayer];
    
    //裁减区域,大小100x100
    _cropZone=[[CALayer alloc] init];
    _cropZone.frame=CGRectMake(w/2-cropCircleSize/2, h/2-cropCircleSize/2, cropCircleSize, cropCircleSize);
    _cropZone.borderColor=[UIColor whiteColor].CGColor;
    _cropZone.borderWidth=1.0f;
    _cropZone.cornerRadius=cropCircleSize/2;
    _cropZone.masksToBounds=YES;
    [self.view.layer addSublayer:_cropZone];
    
    
    //贝塞尔曲线做圆形空洞
    UIBezierPath  *bezier=[UIBezierPath bezierPathWithRect:_bgLayer.frame];
    [bezier appendPath:[UIBezierPath bezierPathWithRoundedRect:_cropZone.frame cornerRadius:cropCircleSize/2]];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.fillRule=kCAFillRuleEvenOdd;
    maskLayer.path = bezier.CGPath;
    _bgLayer.mask=maskLayer;
    //CFRelease(bezier.CGPath);
    
    // 添加移动手势
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [_imageScrollView addGestureRecognizer:panGestureRecognizer];

    //按钮
    UIButton *changeBtn=[UIButton buttonWithType:(UIButtonTypeCustom)];
    changeBtn.frame=CGRectMake(0, h-49, w/2, 49);
    changeBtn.backgroundColor=[UIColor clearColor];
    [changeBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [changeBtn setTitle:@"更换头像" forState:(UIControlStateNormal)];
    changeBtn.titleLabel.font=[UIFont boldSystemFontOfSize:17];
    [changeBtn addTarget:self action:@selector(changeUserHead) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:changeBtn];

    UIButton *sureBtn=[UIButton buttonWithType:(UIButtonTypeCustom)];
    sureBtn.frame=CGRectMake(w/2, h-49, w/2, 49);
    sureBtn.backgroundColor=[UIColor clearColor];
    [sureBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [sureBtn setTitle:@"保存" forState:(UIControlStateNormal)];
    sureBtn.titleLabel.font=[UIFont boldSystemFontOfSize:17];
    [sureBtn addTarget:self action:@selector(cuted) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:sureBtn];
    
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
}

- (void)viewDidDisappear:(BOOL)animated{

    [super viewDidDisappear:animated];
    
}



#pragma mark- event response
//修正图片的方向
- (void)normalizedImage {
    if (_image.imageOrientation != UIImageOrientationUp){
    
        UIGraphicsBeginImageContextWithOptions(_image.size, NO, _image.scale);
        [_image drawInRect:(CGRect){0, 0, _image.size}];
        UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        _image=normalizedImage;
    }
}

// pan gesture handler
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        
    }else if ( panGestureRecognizer.state == UIGestureRecognizerStateChanged){
        
        CGPoint currentPoint=[panGestureRecognizer translationInView:_imageScrollView];
        [_imageScrollView setCenter:(CGPoint){_imageScrollView.center.x +currentPoint.x, _imageScrollView.center.y +currentPoint.y}];
        
        [panGestureRecognizer setTranslation:CGPointZero inView:_imageScrollView];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        [UIView animateWithDuration:animateDuration animations:^{
            [self frameController];
        }];
    }
    
    
}

//保证剪切范围全部在图片上
- (void)frameController {
    
    // horizontally
    
    if (_imageScrollView.frame.origin.x > w/2-cropCircleSize/2)
        _imageScrollView.frame=CGRectMake(w/2-cropCircleSize/2, _imageScrollView.frame.origin.y, _imageScrollView.frame.size.width, _imageScrollView.frame.size.height);
    
    if (CGRectGetMaxX(_imageScrollView.frame) < w/2-cropCircleSize/2+cropCircleSize)
        _imageScrollView.frame=CGRectMake(w/2-cropCircleSize/2+cropCircleSize-_imageScrollView.frame.size.width, _imageScrollView.frame.origin.y, _imageScrollView.frame.size.width, _imageScrollView.frame.size.height);
    
    
    // vertically
    if (_imageScrollView.frame.origin.y > h/2-cropCircleSize/2)
        _imageScrollView.frame=CGRectMake(_imageScrollView.frame.origin.x, h/2-cropCircleSize/2, _imageScrollView.frame.size.width, _imageScrollView.frame.size.height);
    if (CGRectGetMaxY(_imageScrollView.frame) < h/2-cropCircleSize/2+cropCircleSize)
        _imageScrollView.frame=CGRectMake(_imageScrollView.frame.origin.x, h/2-cropCircleSize/2+cropCircleSize-_imageScrollView.frame.size.height, _imageScrollView.frame.size.width, _imageScrollView.frame.size.height);
    
    
}

//修改头像
- (void)changeUserHead{
    
    UIActionSheet *myActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:nil
                                    delegate:self
                                    cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    
    [myActionSheet showInView:self.view];
}

//确认裁剪
- (void)cuted{
    
    [self getSubImage];
}


//剪切
-(void)getSubImage{
    
   
    UIImageView *imageView=(UIImageView *)[_imageScrollView viewWithTag:101];
    CGRect myImageRect = [imageView.layer convertRect:_cropZone.frame fromLayer:_cropZone.superlayer];
    CGImageRef imageRef =_image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef,CGRectMake(myImageRect.origin.x,myImageRect.origin.y,myImageRect.size.width, myImageRect.size.height));
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    [[NSUserDefaults standardUserDefaults] setObject:UIImageJPEGRepresentation(smallImage, 0.7f) forKey:@"localData"];
    [self.navigationController popViewControllerAnimated:YES];
    
}



#pragma mark -UIActionSheetDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    UIImageView *imageView=(UIImageView *)[scrollView viewWithTag:101];
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    UIImageView *imageView=(UIImageView *)[scrollView viewWithTag:101];
    _imageScrollView.contentSize=CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
    _imageScrollView.frame=CGRectMake(scrollView.frame.origin.x-(imageView.frame.size.width-scrollView.frame.size.width)/2,scrollView.frame.origin.y-(imageView.frame.size.height-scrollView.frame.size.height)/2-20 , imageView.frame.size.width,imageView.frame.size.height);
    imageView.center=CGPointMake(_imageScrollView.frame.size.width/2, _imageScrollView.frame.size.height/2);
    
     [self frameController];
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        return; }
    
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
            
        case 1:  //打开本地相册
            [self LocalPhoto];
            break;
    }
    //[actionSheet removeFromSuperview];
}
#pragma mark - UIImagePickerControllerDelegate
- (void)takePhoto{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    }else
    {
        NSLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}
- (void)LocalPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"])
    {
        
        _image = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        [self normalizedImage];
        _imageScrollView.zoomScale=1.0f;
        UIImageView *imageView=(UIImageView *)[_imageScrollView viewWithTag:101];
        [imageView removeFromSuperview];
        imageView=nil;
        UIImageView *newimageView=[[UIImageView alloc] init];
        newimageView.frame=CGRectMake(0, 0, _image.size.width, _image.size.height);
        newimageView.image=_image;
        newimageView.tag=101;
        [_imageScrollView addSubview:newimageView];
        _imageScrollView.minimumZoomScale=MAX(cropCircleSize/_image.size.width, cropCircleSize/_image.size.height);
        _imageScrollView.maximumZoomScale=_imageScrollView.minimumZoomScale*4;
        _imageScrollView.zoomScale=MIN(w/_image.size.width, h/_image.size.height);
    
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
