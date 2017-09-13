//
//  AGLKVertexAttribArrayBuffer.m
//  YYH_GLKit_02Texture
//
//  Created by 杨昱航 on 2017/6/14.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import "AGLKVertexAttribArrayBuffer.h"

@implementation AGLKVertexAttribArrayBuffer

-(id)initWithAttribStride:(GLsizei)stride numberOfVertices:(GLsizei)count data:(const GLvoid *)dataPtr usage:(GLenum)usage
{
    NSParameterAssert(0<stride);
    NSParameterAssert(0<count);
    NSParameterAssert(NULL!=dataPtr);
    
    if (self=[super init])
    {
        _stride=stride;
        _bufferSizeBytes=stride*count;
        
        glGenBuffers(1, &_glName);//1、为缓存生成一个独一无二的标识符
        glBindBuffer(GL_ARRAY_BUFFER, _glName);//2、为接下来的应用绑定缓存
        glBufferData(GL_ARRAY_BUFFER, _bufferSizeBytes, dataPtr, usage);//3、复制数据到缓存中
        
        NSAssert(0!=_glName, @"生产唯一标识符失败");
    }
    return self;
}

-(void)prepareToDrawWithAttrib:(GLint)index numberOfCoordinates:(GLint)count attribOffset:(GLsizei)offset shouldEnable:(BOOL)shouldEnable
{
    NSParameterAssert((0<count) && (count<=4));
    NSParameterAssert(offset < self.stride);
    
    if(shouldEnable){
        glEnableVertexAttribArray(index);//4.启动顶点缓存渲染操作
    }
    
    glVertexAttribPointer(index, count, GL_FLOAT, GL_FALSE, self.stride, NULL+offset);//5、告诉OpenGL ES顶点数据在哪里，以及解释为每个顶点保存的数据
}

-(void)drawArrayWithMode:(GLenum)mode starVertexIndex:(GLint)first numberOfVertices:(GLsizei)count
{
    NSAssert(self.bufferSizeBytes>=(first+count)*self.stride, @"试图渲染多于可用数量的顶点");
    
    glDrawArrays(mode, first, count);//6.绘图
}


-(void)dealloc
{
    if (0!=_glName) {
        glDeleteBuffers(1, &_glName);
        _glName=0;
    }
}





@end
