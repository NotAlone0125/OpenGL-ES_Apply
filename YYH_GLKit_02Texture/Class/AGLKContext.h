//
//  AGLKContext.h
//  YYH_GLKit_02Texture
//
//  Created by 杨昱航 on 2017/6/14.
//  Copyright © 2017年 杨昱航. All rights reserved.
//
#import <GLKit/GLKit.h>
//#import <OpenGLES/OpenGLES.h>


//AGLKContext类是一个在例子YYH_GLKit_01中使用的内建的EAGLContext类的简单子类。重构后的AGLKContext仅仅添加了一个clearColor属性和一个用来告诉OpenGL ES去设置上下文的帧缓存的每个像素颜色为clearColor的元素值得“-clear:”的方法。
@interface AGLKContext : EAGLContext
{
    GLKVector4 _clearColor;
}
@property (nonatomic,assign)GLKVector4 clearColor;

-(void)clear:(GLbitfield)mask;

@end
