//
//  AGLKVertexAttribArrayBuffer.h
//  YYH_GLKit_02Texture
//
//  Created by 杨昱航 on 2017/6/14.
//  Copyright © 2017年 杨昱航. All rights reserved.
//
#import <GLKit/GLKit.h>
#import <Foundation/Foundation.h>

//AGLKVertexAttribArrayBuffer类封装了使用OpenGL ES2.0的顶点属性数组缓存（或者简称“顶点缓存”的所有7个步骤）。这个函数减少了应用需要调用的OpenGL ES的函数的数量
@interface AGLKVertexAttribArrayBuffer : NSObject

@property (nonatomic,readonly) GLsizei stride;//顶点数组单个元素缓存字节的数量额
@property (nonatomic,readonly) GLsizeiptr bufferSizeBytes;//指定要复制这个缓存字节的数量
@property (nonatomic,readonly) GLuint glName;//保存了用于盛放本例中用到的顶点数据的缓存的OpenGl ES标识符

-(id)initWithAttribStride:(GLsizei)stride numberOfVertices:(GLsizei)count data:(const GLvoid *)dataPtr usage:(GLenum)usage;

-(void)prepareToDrawWithAttrib:(GLint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizei)offset shouldEnable:(BOOL)shouldEnable;

-(void)drawArrayWithMode:(GLenum)mode starVertexIndex:(GLint)first numberOfVertices:(GLsizei)count;

@end
