//
//  GLKitView.h
//  WordArtProject
//
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <GLKit/GLKit.h>
#import <OpenGLES/EAGLDrawable.h>
@protocol GLKitViewDelegate<NSObject>
-(void) renderGL;
@end
@interface GLKitView : UIView
@property(nonatomic,strong) EAGLContext *mContext;
@property(nonatomic,weak) id<GLKitViewDelegate> delegate;
@property(nonatomic,assign)GLint backingWidth;
@property(nonatomic,assign)GLint backingHeight;
//开始渲染
-(void) beginRender;
//执行渲染
-(void) renderFrame;
-(instancetype)initWithFrame:(CGRect)frame context:(EAGLContext *) context;
@end
