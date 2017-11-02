//
//  GLKitHelper.h
//  DrawAStraightLine
//
//  Created by richsjeson on 2017/10/25.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGLDrawable.h>
#import <UIKit/UIKit.h>

typedef struct {
    GLuint id;
    GLsizei width, height;
} textureInfo_t;


@protocol GLKHelperDelegate<NSObject>
- (void)glTouchesBegan:(CGPoint) start  end:(CGPoint)end;
- (void)glTouchesMoved:(CGPoint) start  end:(CGPoint)end;
- (void)glTouchesEnded:(CGPoint) start  end:(CGPoint)end;
@end
@interface GLKitHelper : NSObject
-(UIImage *) glToUIImage;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *) view;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *) view;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event view:(UIView *) view;
@property(nonatomic,readwrite) CGPoint location;
@property(nonatomic,readwrite) CGPoint previousLocation;
@property(nonatomic,weak) id<GLKHelperDelegate> delegate;
//创建纹理
- (textureInfo_t)createTexture:(NSString *)name;
-(void)saveImageDocuments:(UIImage *)image named:(NSString*)names;
-(NSMutableArray *)getDocumentImage;
-(void) productGif:(NSMutableArray *) imageArray;
@end
