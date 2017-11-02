//
//  Particle.m
//  WordArtProject
//  粒子渲染
//  Created by richsjeson on 2017/10/27.
//  Copyright © 2017年 richsjeson. All rights reserved.
//

#import "ParticleRenderer.h"
typedef NS_ENUM(NSInteger,BaseRenderer_Particle){
    VERTEX=0,
    EMISSION_VELOCITY=1,
    EMISSION_FORCE=2,
    EMISSION_SIZE=3,
    EMISSION_DEATHTIME=4,
    PARTICLE_SIZE=5,
};

typedef NS_ENUM(NSInteger,UNIFORM_Particle){
    MVP_MATRIX=0,
    TEXTURE=1,
    GRAVITY=2,
    ELASPED_SECONDS=3,
    UNIFORM_SIZE=4,
};
@interface ParticleRenderer(){
    //创建渲染管理器
    GLint program;
    GLuint   vboId;
    GLuint   vAoId;
    GLint uniforms[UNIFORM_SIZE];
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
    
    glBindAttribLocation(program,VERTEX,
                         "inVertex");
    glBindAttribLocation(program, EMISSION_VELOCITY,
                         "a_emissionVelocity");
    glBindAttribLocation(program, EMISSION_FORCE,
                         "a_emissionForce");
    glBindAttribLocation(program, EMISSION_SIZE,
                         "a_size");
    glBindAttribLocation(program, EMISSION_DEATHTIME,
                         "a_emissionAndDeathTimes");
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
    
    // Get uniform locations.
    uniforms[MVP_MATRIX] = glGetUniformLocation(program,
                                                   "u_mvpMatrix");
    uniforms[TEXTURE] = glGetUniformLocation(program,
                                                    "u_samplers2D");
    uniforms[GRAVITY] = glGetUniformLocation(program,
                                                 "u_gravity");
    uniforms[ELASPED_SECONDS] = glGetUniformLocation(program,
                                                        "u_elapsedSeconds");
    
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

-(void) drawLine:(CGPoint) start endPoint:(CGPoint) end{
    //此时拿到了粒子的元素
    static GLfloat*        squareVertexData = NULL;
    // Convert locations from Points to Pixels
    CGFloat scale = self.scale;
    start.x *= scale;
    start.y *= scale;
    end.x *= scale;
    end.y *= scale;
    
    // Allocate vertex array buffer
    if(squareVertexData == NULL){
        squareVertexData = malloc(4* sizeof(GLfloat));
    }
    //绘制鼠标点击事件的顶点数组
    squareVertexData[0] = start.x + (end.x - start.x);
    squareVertexData[1] = start.y + (end.y - start.y);
    glGenBuffers(1, &vboId);
    glError();
    glBindBuffer(GL_ARRAY_BUFFER, vboId);
    glError();
    glBufferData(GL_ARRAY_BUFFER,4*sizeof(CGFloat), squareVertexData, GL_DYNAMIC_DRAW);
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
    glDrawArrays(GL_POINTS, 0,2);
    glError();
}

@end
