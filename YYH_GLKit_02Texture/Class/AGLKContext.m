//
//  AGLKContext.m
//  YYH_GLKit_02Texture
//
//  Created by 杨昱航 on 2017/6/14.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import "AGLKContext.h"

@implementation AGLKContext

//设置当前OpenGL ES的上下文的“清除颜色”（set方法）
-(void)setClearColor:(GLKVector4)clearColor
{
    _clearColor=clearColor;
    
    glClearColor(clearColor.r,clearColor.g,clearColor.b,clearColor.a);
}

//获得当前的OpenGL ES的上下文的“清除颜色”（get方法）
-(GLKVector4)clearColor
{
    return _clearColor;
}

//清除颜色缓冲
-(void)clear:(GLbitfield)mask
{
    glClear(mask);
}

@end
