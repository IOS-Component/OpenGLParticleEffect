//
//  Particle.m
//  WordArtProject
//  粒子渲染
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "ParticleRenderer.h"
@interface ParticleRenderer(){
    //创建渲染管理器
    GLint program;
    GLuint   vboId;
    GLuint   vAoId;
}
@end
@implementation ParticleRenderer


-(void) prepareToDraw{
    if(program==0){
        //创建渲染层
        [self createShader];
    }
    if(program != 0){
        //渲染时赋值
        glUseProgram(program);
        
    }
}

-(BOOL) createShader{
    GLuint vertexShader, fragmentShader;
    NSString *vertexShaderSource, *fragmentShaderSource;
    
    program=glCreateProgram();
    
    //创建顶点渲染器
    vertexShaderSource = [[NSBundle mainBundle] pathForResource:
                          @"particle" ofType:@"vsh"];
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER
                        file:vertexShaderSource])
    {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    // 创建片段渲染器.
    fragmentShaderSource = [[NSBundle mainBundle] pathForResource:
                            @"particle" ofType:@"fsh"];
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



@end
