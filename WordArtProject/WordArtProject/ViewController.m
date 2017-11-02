//
//  ViewController.m
//  WordArtProject
//
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "ViewController.h"
#import "GLKitView.h"
#import "GLKitHelper.h"
#import "BrushRenderer.h"
#import "AGLKPointParticleEffect.h"
#define kBrightness             1.0
#define kSaturation             0.45

#define kPaletteHeight            30
#define kPaletteSize            5
#define kMinEraseInterval        0.5

// Padding for margins
#define kLeftMargin                10.0
#define kTopMargin                10.0
#define kRightMargin            10.0

#define  WIDTH  [[UIScreen mainScreen] bounds].size.width
#define  HEIGHT [[UIScreen mainScreen] bounds].size.height
#define  SCALE  [UIScreen mainScreen].scale
@interface ViewController ()<GLKitViewDelegate,GLKHelperDelegate>{
    
    NSTimeInterval firstTime;
    BOOL initialiszed;
    CGPoint startPoint;
}
@property(nonatomic,strong) GLKitView * glkView;
@property(nonatomic,strong) GLKitHelper *glkHelper;
@property(nonatomic,strong) BrushRenderer * brushRenderer;
@property(nonatomic,strong) EAGLContext * mContext;
@property(nonatomic,strong) AGLKPointParticleEffect * coffieEffect;
@property(nonatomic,strong) CADisplayLink * displayLink;
@property(nonatomic,assign) NSTimeInterval timeSinceFirstResume;
@property (assign, nonatomic) NSTimeInterval autoSpawnDelta;
@property (assign, nonatomic) NSTimeInterval lastSpawnTime;
@property (nonatomic , assign) long mElapseTime;
@end


@implementation ViewController
@synthesize glkView;
@synthesize glkHelper;
@synthesize brushRenderer;
@synthesize mContext;
@synthesize coffieEffect;


- (void)viewDidLoad {
    [super viewDidLoad];
    //
    firstTime = [[NSDate date] timeIntervalSince1970];
    self.mElapseTime=0;
    
    mContext=[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    CGColorRef color = [UIColor colorWithHue:(CGFloat)2.0 / (CGFloat)kPaletteSize
                                  saturation:kSaturation
                                  brightness:kBrightness
                                       alpha:1.0].CGColor;
    const CGFloat *components = CGColorGetComponents(color);
    if(!glkView){
        glkView=[[GLKitView alloc] initWithFrame:self.view.bounds context:mContext];
        glkView.backingWidth=WIDTH*SCALE;
        glkView.backingHeight=HEIGHT*SCALE;
        glkView.delegate=self;
        [self.view addSubview:glkView];
    }
    if(!glkHelper){
        glkHelper=[[GLKitHelper alloc] init];
        glkHelper.delegate=self;
    }
    
    if(!brushRenderer){
        brushRenderer=[[BrushRenderer alloc] init];
        brushRenderer.renderProjectionMatrix=GLKMatrix4MakeOrtho(0,WIDTH*SCALE,0, HEIGHT*SCALE, -1, 1);
        brushRenderer.renderModelViewMatrix=GLKMatrix4Identity;
        brushRenderer.scale=SCALE;
        [brushRenderer colorWithRed:components[0] green:components[1] blue:components[2]];
    }
    glClearColor(0.3, 0.3, 0.3, 1);
    [EAGLContext setCurrentContext:mContext];
    
    if(!coffieEffect){
        coffieEffect=[[AGLKPointParticleEffect alloc] init];
        [self preparePointOfViewWithAspectRatio:
         CGRectGetWidth(self.view.bounds) / CGRectGetHeight(self.view.bounds)];
    }
    
    NSString *path = [[NSBundle bundleForClass:[self class]]
                      pathForResource:@"ball" ofType:@"png"];
    NSAssert(nil != path, @"ball texture image not found");
    NSError *error = nil;
    GLKTextureInfo *ballParticleTexture = [GLKTextureLoader
                                textureWithContentsOfFile:path
                                options:nil
                                error:&error];
    self.coffieEffect.texture2d0.name =
    ballParticleTexture.name;
    self.coffieEffect.texture2d0.target =
    ballParticleTexture.target;
    
    self.displayLink=[CADisplayLink displayLinkWithTarget:self
                                selector:@selector(display)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop]
                      forMode:NSDefaultRunLoopMode];
}

//MVP矩阵
- (void)preparePointOfViewWithAspectRatio:(GLfloat)aspectRatio
{
    self.coffieEffect.transform.projectionMatrix =
    GLKMatrix4MakePerspective(
                              GLKMathDegreesToRadians(85.0f),
                              aspectRatio,
                              0.1f,
                              1.0f);
    
    self.coffieEffect.transform.modelviewMatrix =
    GLKMatrix4MakeLookAt(
                         0.0, 0.0, 1.0,   // Eye position
                         0.0, 0.0, 0.0,   // Look-at position
                         0.0, 1.0, 0.0);  // Up direction
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) renderGL{
    
//
    if(brushRenderer && glkHelper){
        textureInfo_t texure=[glkHelper createTexture:@"Particle"];
        brushRenderer.pointSize=texure.width/2;
        [brushRenderer prepareToDraw];
    }
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    [coffieEffect prepareToDraw];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(glkHelper){
        [glkHelper touchesBegan:touches withEvent:event view:glkView];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(glkHelper){
        [glkHelper touchesEnded:touches withEvent:event view:glkView];
    }
//    //生成gif;
//    NSMutableArray *imageArray=[glkHelper getDocumentImage];
//    [glkHelper productGif:imageArray];
    
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(glkHelper){
        [glkHelper touchesMoved:touches withEvent:event view:glkView];
    }
}

-(void) touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
}

- (void)glTouchesBegan:(CGPoint) start  end:(CGPoint)end{
     startPoint=start;
}
- (void)glTouchesMoved:(CGPoint) start  end:(CGPoint)end{
    startPoint=start;
    [self glTouchesEnded:start end:end];
}
- (void)glTouchesEnded:(CGPoint) start  end:(CGPoint)end{
    startPoint=start;
    if(glkView && brushRenderer){
        [glkView beginRender];
        [brushRenderer drawLine:start endPoint:end];
        [glkView renderFrame];
    }
}



- (void)glkView:(UIView *)view drawInRect:(CGRect)rect{
    ++self.mElapseTime;
    self.timeSinceFirstResume=[[NSDate date] timeIntervalSince1970]-firstTime;
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.3, 0.3, 0.3, 1);
    glFramebufferTexture2D(<#GLenum target#>, <#GLenum attachment#>, <#GLenum textarget#>, <#GLuint texture#>, <#GLint level#>);
    [self update];
    [coffieEffect prepareToDraw];
    [coffieEffect draw];
}


-(void) update{
   
    NSInteger width=WIDTH;
    NSInteger height=HEIGHT;
    
    CGFloat  startX=startPoint.x/width;
    CGFloat  startY=startPoint.y/height;
    
    CGFloat  endX = startPoint.x/width - 0.5f;
    CGFloat  endY = startPoint.y/height * 2 - 1.f ;
    self.autoSpawnDelta = 0.5f;
    self.coffieEffect.gravity = GLKVector3Make(
                                               0.0f, 0.0f, 0.0f);

    self.coffieEffect.elapsedSeconds=self.timeSinceFirstResume;
    if(self.autoSpawnDelta < (self.timeSinceFirstResume - self.lastSpawnTime))
    {
        self.lastSpawnTime = self.timeSinceFirstResume;
        for(int i = 0; i < 100; i++)
        {
            float randomXVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomYVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            float randomZVelocity = -0.5f + 1.0f *
            (float)random() / (float)RAND_MAX;
            
            [self.coffieEffect
             addParticleAtPosition:GLKVector3Make(endX, endY, 0.0f)
             velocity:GLKVector3Make(
                                     randomXVelocity,
                                     randomYVelocity,
                                     randomZVelocity)
             force:GLKVector3Make(endX, endY, 0.0f)
             size:4.0f
             lifeSpanSeconds:3.2f
             fadeDurationSeconds:0.5f];
        }
//        UIImage * image=[glkHelper glToUIImage];
//        [glkHelper saveImageDocuments:image named:[NSString stringWithFormat:@"test_%@",[NSString stringWithFormat:@"%f",self.lastSpawnTime]]];
    }
}

-(void) display{
    [glkView display];
}


@end
