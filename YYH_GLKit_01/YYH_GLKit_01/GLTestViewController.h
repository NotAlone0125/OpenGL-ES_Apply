//
//  GLTestViewController.h
//  YYH_GLKit_01
//
//  Created by 杨昱航 on 2017/6/14.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface GLTestViewController : GLKViewController
{
    GLuint vertexBufferID;
}
@property(nonatomic,strong)GLKBaseEffect * baseEffect;
/*
 GLKViewController的基本功能(如：接收当视图需要重绘时的消息)。
 vertexBufferID变量保存了用于盛放本例中用到的顶点数据的缓存的OpenGL ES标识符。
 baseEffect属性声明了一个GLKBaseEffect实例的指针。GLKBaseEffect是GLKit提供的另一个内建类。GLKBaseEffect的存在是为了简化OpenGL ES的很多常用的操作。GLKBaseEffect隐藏了iOS设备支持的多了OPenGL ES版本间的差异。在应用中使用GLKBaseEffect能减少需要编写的代码量。
 */
@end
