//
//  ViewController.h
//  YYH_OpenGL ES05_灯光_01
//
//  Created by 杨昱航 on 2017/6/26.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "AGLKVertexAttribArrayBuffer.h"
#import "AGLKContext.h"

@interface ViewController : GLKViewController

@property (strong, nonatomic) GLKBaseEffect
*baseEffect;
@property (strong, nonatomic) GLKBaseEffect
*extraEffect;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer
*vertexBuffer;
@property (strong, nonatomic) AGLKVertexAttribArrayBuffer
*extraBuffer;

@property (nonatomic) GLfloat
centerVertexHeight;
@property (nonatomic) BOOL
shouldUseFaceNormals;
@property (nonatomic) BOOL
shouldDrawNormals;

- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender;
- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender;
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender;

@end

