//
//  FMImagePicker.m
//  Client
//
//  Created by mingo on 2018/12/25.
//  Copyright © 2018年 mingo. All rights reserved.
//

#import "FMImagePicker.h"

@interface FMImagePicker ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    
}
/** <#注释#>*/
@property (nonatomic, copy) FMImagePickerBlock imagePicker;
@property (nonatomic, assign) CGFloat scale;
@end


@implementation FMImagePicker

- (void )fm_imagePickerTitle:(NSString *)title alertStyle:(UIAlertControllerStyle)style toScale:(CGFloat)scale imagePickerBlock:(FMImagePickerBlock)imagePicker {
    self.imagePicker = imagePicker;
    self.scale = scale;
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:style];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openAlbum];
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
    }];
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    
    [actionSheet addAction:action1];
    [actionSheet addAction:action2];
    [actionSheet addAction:action3];
    [[self fm_getCurrentViewController] presentViewController:actionSheet animated:YES completion:nil];

}


/**
 *  打开照相机
 */
- (void)openCamera
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
    ipc.delegate = self;
    [[self fm_getCurrentViewController] presentViewController:ipc animated:YES completion:nil];
}

/**
 *  打开相册
 */
- (void)openAlbum
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    ipc.delegate = self;
    [[self fm_getCurrentViewController] presentViewController:ipc animated:YES completion:nil];
    
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
     __weak __typeof(self)weakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        // 1.取出选中的图片
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        if (self.imagePicker) {
            self.imagePicker([weakSelf scaleImage:image toScale:self.scale]);
        }
//        [ fm_kurl_hzUpdateImage:image];
        //        image = [image resizeImageWithSize:CGSizeZero];
        // 2.添加图片到相册中
        //        weakSelf.lookPic.image = image;
        //        [self addRemoveImageButton];
    }];
}


-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 私有方法

- (UIImage *)scaleImage:(UIImage *)scaleImage toScale:(float)scaleSize{
    
    CGFloat sizeWith = scaleImage.size.width * scaleSize;
    CGFloat sizeHeight = scaleImage.size.height * scaleSize;
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sizeWith, sizeHeight), NO, 0.0);
    
    [scaleImage drawInRect:CGRectMake(0, 0, sizeWith, sizeHeight)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - 获取当前屏幕显示的VC
- (UIViewController *)fm_getCurrentViewController {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentVC = [self getCurrentVCFrom:rootViewController];
    return currentVC;
}

- (UIViewController *)getCurrentVCFrom:(UIViewController *)rootVC {
    UIViewController *currentVC;
    if([rootVC presentedViewController]) {
        // 视图是被presented出来的
        rootVC = [rootVC presentedViewController];
    }
    if([rootVC isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        currentVC = [self getCurrentVCFrom:[(UITabBarController *)rootVC selectedViewController]];
    }else if([rootVC isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        currentVC = [self getCurrentVCFrom:[(UINavigationController *)rootVC visibleViewController]];
    }else{
        // 根视图为非导航类
        currentVC = rootVC;
    }
    return currentVC;
}

@end
