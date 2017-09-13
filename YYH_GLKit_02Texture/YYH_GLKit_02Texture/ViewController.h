//
//  ViewController.h
//  YYH_GLKit_02Texture
//
//  Created by 杨昱航 on 2017/6/14.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

#import "AGLKContext.h"
#import "AGLKVertexAttribArrayBuffer.h"

//重构OpenGL ES 01-GLKit 的可重用OpenGL ES代码为两个新类：AGLKContext和AGLKVertexAttribArrayBuffer。

@interface ViewController : GLKViewController
@property (nonatomic,strong) GLKBaseEffect *baseEffect;
@property (nonatomic,strong) AGLKVertexAttribArrayBuffer *vertexBuffer;

@end

