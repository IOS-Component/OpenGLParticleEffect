//
//  BrushRenderer.m
//  WordArtProject
//  画笔渲染层
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "BrushRenderer.h"
#define kBrushOpacity        (1.0 / 3.0)
#define kBrushPixelStep        3
#define kBrushScale            2
typedef NS_ENUM(NSInteger,BaseRenderer_Brush){
    MVP_MATRIX=0,
    POINT_SIZE=1,
    VERTEX_COLOR=2,
    TEXTURE=3,
    BRUSH_UNIFORM=4,
};
@interface BrushRenderer(){
    //创建渲染管理器
    GLint program;
    GLint uniforms[BRUSH_UNIFORM];
    GLfloat brushColor[4];
    GLuint   vboId;
    GLuint   vAoId;
}
@end
@interface BrushRenderer(){

    
}
@end
@implementation BrushRenderer
-(void) prepareToDraw{
    
    if(program==0){
        //创建渲染层
        [self createShader];
    }
    
    if(program != 0){
        //渲染时赋值
        glUseProgram(program);
        glUniform1i(uniforms[TEXTURE], 0);
        GLKMatrix4 MVPMatrix = GLKMatrix4Multiply(self.renderProjectionMatrix,self.renderModelViewMatrix);
        glUniformMatrix4fv(uniforms[MVP_MATRIX],1, GL_FALSE, MVPMatrix.m);
        glUniform1f(uniforms[POINT_SIZE], self.pointSize);
        glUniform4fv(uniforms[VERTEX_COLOR], 1, brushColor);
    }
}
-(BOOL) createShader{
    GLuint vertexShader, fragmentShader;
    NSString *vertexShaderSource, *fragmentShaderSource;
    
    program=glCreateProgram();
    
    //创建顶点渲染器
    vertexShaderSource = [[NSBundle mainBundle] pathForResource:
                          @"point" ofType:@"vsh"];
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER
                               file:vertexShaderSource])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // 创建片段渲染器.
    fragmentShaderSource = [[NSBundle mainBundle] pathForResource:
                            @"point" ofType:@"fsh"];
    if (![super compileShader:&fragmentShader type:GL_FRAGMENT_SHADER
                               file:fragmentShaderSource])
    {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertexShader);
    glError();
    // Attach fragment shader to program.
    glAttachShader(program, fragmentShader);
    glError();
    
    glBindAttribLocation(program,0,
                         "inVertex");
    glError();
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertexShader)
        {
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        if (fragmentShader)
        {
            glDeleteShader(fragmentShader);
            fragmentShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return NO;
    }
    
    //    // Get uniform locations.
    uniforms[MVP_MATRIX] = glGetUniformLocation(program,"MVP");
    uniforms[POINT_SIZE] = glGetUniformLocation(program,"pointSize");
    uniforms[VERTEX_COLOR] = glGetUniformLocation(program,"vertexColor");
    uniforms[TEXTURE] = glGetUniformLocation(program,"texture");
    glError();
    // Delete vertex and fragment shaders.
    if (vertexShader)
    {
        glDetachShader(program, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader)
    {
        glDetachShader(program, fragmentShader);
        glDeleteShader(fragmentShader);
    }
    return YES;
}

//绘制顶点数组
-(void) drawLine:(CGPoint) start endPoint:(CGPoint) end{
    static GLfloat*        squareVertexData = NULL;
    static NSUInteger    vertexMax = 64;
    NSUInteger            vertexCount = 0,
    count,
    i;
    // Convert locations from Points to Pixels
    CGFloat scale = self.scale;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;
    
    // Allocate vertex array buffer
    if(squareVertexData == NULL)
        squareVertexData = malloc(vertexMax * 2 * sizeof(GLfloat));
    // Add points to the buffer so there are@property(nonatomic,assign) GLKMatrix4 renderModelViewMatrix drawing points every X pixels
    count = MAX(ceilf(sqrtf((end.x - start.x) * (end.x - start.x) + (end.y - start.y) * (end.y - start.y)) / kBrushPixelStep), 1);
    for(i = 0; i < count; ++i) {
        if(vertexCount == vertexMax) {
            vertexMax = 2 * vertexMax;
            squareVertexData = realloc(squareVertexData, vertexMax * 2 * sizeof(GLfloat));
        }
        squareVertexData[2 * vertexCount + 0] = start.x + (end.x - start.x) * ((GLfloat)i / (GLfloat)count);
        squareVertexData[2 * vertexCount + 1] = start.y + (end.y - start.y) * ((GLfloat)i / (GLfloat)count);
        vertexCount += 1;
        NSLog(@"x:%f,y:%f",squareVertexData[2*vertexCount+0],squareVertexData[2*vertexCount+1]);
    }
    glGenBuffers(1, &vboId);
    glError();
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glError();
    glBufferData(GL_ARRAY_BUFFER, vertexCount*2*sizeof(CGFloat), squareVertexData, GL_DYNAMIC_DRAW);
    glError();
    //设置顶点数组对象VAO；
    glGenVertexArrays(1, &vAoId);
    glError();
    // 开始记录
    glBindVertexArray(vAoId);
    glError();
    glEnableVertexAttribArray(GLKVertexAttribPosition); //顶点数据缓存
    glError();
    glBindVertexArray(1);
    glError();
    glVertexAttribPointer(GLKVertexAttribPosition, 2, GL_FLOAT, GL_FALSE,0,0);
    glError();
    glError();
    glUseProgram(program);
    glDrawArrays(GL_POINTS, 0,(int) vertexCount);
    glError();
}
- (void)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue
{
    // Update the brush color
    brushColor[0] = red * kBrushOpacity;
    brushColor[1] = green * kBrushOpacity;
    brushColor[2] = blue * kBrushOpacity;
    brushColor[3] = kBrushOpacity;
}
@end
