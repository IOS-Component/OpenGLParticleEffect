//
//  GLKitHelper.m
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/25.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "GLKitHelper.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>
@interface GLKitHelper(){
    Boolean firstTouch;
}
@end
@implementation GLKitHelper
@synthesize location;
@synthesize previousLocation;
//图片截取
-(UIImage *) glToUIImage {
    //计算fen'bian'lv
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    GLint width= size_screen.width*scale_screen;// CGRectGetWidth(self.view.bounds)*4;
    GLint height= size_screen.height*scale_screen;//CGRectGetHeight(self.view.bounds)*4;
    NSInteger myDataLength = width *height * 4;
    
    // allocate array and read pixels into it.
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    // gl renders "upside down" so swap top to bottom into new array.
    // there's gotta be a better way, but this works.
    //    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
    //    for(int y = 0; y <height; y++)
    //    {
    //        for(int x = 0; x <width * 4; x++)
    //        {
    //            buffer2[(height-1 - y) * width * 4 + x] = buffer[y * 4 * width + x];
    //        }
    //    }
    //
    // make data provider with data.
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, NULL);
    //    width/=2;
    //    height/=2;
    // prep the ingredients
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    // make the cgimage
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    // then make the uiimage from that
    UIImage *myImage = [UIImage imageWithCGImage:imageRef];
    return myImage;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *) view
{
    CGRect                bounds = [view bounds];
    UITouch*            touch = [[event touchesForView:view] anyObject];
    firstTouch = YES;
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    location = [touch locationInView:view];
    location.y = bounds.size.height - location.y;
    if(self.delegate && [self.delegate respondsToSelector:@selector(glTouchesBegan:end:)]){
        [self.delegate glTouchesBegan:location end:location];
    }
}

// Handles the continuation of a touch.
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *) view
{
    CGRect                bounds = [view bounds];
    UITouch*            touch = [[event touchesForView:view] anyObject];
    
    // Convert touch point from UIView referential to OpenGL one (upside-down flip)
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:view];
        previousLocation.y = bounds.size.height - previousLocation.y;
    } else {
        location = [touch locationInView:view];
        location.y = bounds.size.height - location.y;
        previousLocation = [touch previousLocationInView:view];
        previousLocation.y = bounds.size.height - previousLocation.y;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(glTouchesMoved:end:)]){
        [self.delegate glTouchesMoved:previousLocation end:location];
    }
}

// Handles the end of a touch event when the touch is a tap.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *) view
{
    CGRect                bounds = [view bounds];
    UITouch*            touch = [[event touchesForView:view] anyObject];
    if (firstTouch) {
        firstTouch = NO;
        previousLocation = [touch previousLocationInView:view];
        previousLocation.y = bounds.size.height - previousLocation.y;
        if(self.delegate && [self.delegate respondsToSelector:@selector(glTouchesEnded:end:)]){
            [self.delegate glTouchesEnded:previousLocation end:location];
        }
    }
}

- (textureInfo_t)createTexture:(NSString *)name
{
    CGImageRef        brushImage;
    CGContextRef    brushContext;
    GLubyte            *brushData;
    size_t            width, height;
    GLuint          texId;
    textureInfo_t   texture;
    
    // First create a UIImage object from the data in a image file, and then extract the Core Graphics image
    brushImage = [UIImage imageNamed:name].CGImage;
    
    // Get the width and height of the image
    width = CGImageGetWidth(brushImage);
    height = CGImageGetHeight(brushImage);
    
    // Make sure the image exists
    if(brushImage) {
        // Allocate  memory needed for the bitmap context
        brushData = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
        // Use  the bitmatp creation function provided by the Core Graphics framework.
        brushContext = CGBitmapContextCreate(brushData, width, height, 8, width * 4, CGImageGetColorSpace(brushImage), kCGImageAlphaPremultipliedLast);
        // After you create the context, you can draw the  image to the context.
        CGContextDrawImage(brushContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), brushImage);
        // You don't need the context at this point, so you need to release it to avoid memory leaks.
        CGContextRelease(brushContext);
        // Use OpenGL ES to generate a name for the texture.
        glGenTextures(1, &texId);
        // Bind the texture name.
        glBindTexture(GL_TEXTURE_2D, texId);
        // Set the texture parameters to use a minifying filter and a linear filer (weighted average)
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        // Specify a 2D texture image, providing the a pointer to the image data in memory
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, brushData);
        // Release  the image data; it's no longer needed
        free(brushData);
        
        texture.id = texId;
        texture.width = (int)width;
        texture.height = (int)height;
    }
    
    return texture;
}

//保存图片
-(void)saveImageDocuments:(UIImage *)image named:(NSString*)names{
    //拿到图片
    UIImage *imagesave = image;
    NSString *path_sandox = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath = [path_sandox stringByAppendingString:[NSString stringWithFormat:@"/Documents/%@.png",names]];
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(imagesave) writeToFile:imagePath atomically:YES];
}

//生成gif图片
-(void) productGif:(NSMutableArray *) imageArray{
    //创建爱你gif文件
    NSArray *document = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *doucmentStr =[document objectAtIndex:0];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSString *textDic = [doucmentStr stringByAppendingString:@"/gif"];
    [filemanager createDirectoryAtPath:textDic withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *path = [textDic stringByAppendingString:@"article_particel.gif"];
    NSLog(@"-----%@",path);
    //配置gif属性
    CGImageDestinationRef destion;
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)path, kCFURLPOSIXPathStyle, false);
    destion = CGImageDestinationCreateWithURL(url, kUTTypeGIF, imageArray.count, NULL);
    NSDictionary *frameDic = [NSDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.3],(NSString*)kCGImagePropertyGIFDelayTime, nil] forKey:(NSString*)kCGImagePropertyGIFDelayTime];
    
    NSMutableDictionary *gifParmdict = [NSMutableDictionary dictionaryWithCapacity:25];
    [gifParmdict setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
    [gifParmdict setObject:(NSString*)kCGImagePropertyColorModelRGB forKey:(NSString*)kCGImagePropertyColorModel];
    [gifParmdict setObject:[NSNumber numberWithInt:8] forKey:(NSString*)kCGImagePropertyDepth];
    [gifParmdict setObject:[NSNumber numberWithInt:0] forKey:(NSString*)kCGImagePropertyGIFLoopCount];
    NSDictionary *gifProperty = [NSDictionary dictionaryWithObject:gifParmdict forKey:(NSString*)kCGImagePropertyGIFDictionary];
    
    for (UIImage *dimage in imageArray) {
        CGImageDestinationAddImage(destion, dimage.CGImage, (__bridge CFDictionaryRef)frameDic);
    }
    
    CGImageDestinationSetProperties(destion,(__bridge CFDictionaryRef)gifProperty);
    CGImageDestinationFinalize(destion);
    CFRelease(destion);
}

//读取png,并加入gif图片中
-(NSMutableArray *)getDocumentImage{
    NSMutableArray *array=[[NSMutableArray alloc] init];
    NSFileManager * file=[NSFileManager defaultManager];
    NSString * docDirectionary=[NSString stringWithFormat:@"%@/Documents",NSHomeDirectory()];
    NSArray * subPaths=[file contentsOfDirectoryAtPath:docDirectionary error:nil];
    if(subPaths){
        for(NSString * sub in subPaths){
            if([sub hasPrefix:@"test_"]){
                NSLog(@"获取test_的路径为:%@",sub);
                NSString *aPath=[NSString stringWithFormat:@"%@/Documents/%@.png",NSHomeDirectory(),sub];
                // 拿到沙盒路径图片
                UIImage *imgFromUrl3=[[UIImage alloc]initWithContentsOfFile:aPath];
                [array addObject:imgFromUrl3];
            }
        }
    }
    return array;
   
}
@end
