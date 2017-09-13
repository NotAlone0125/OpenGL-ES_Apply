//
//  ViewController.m
//  YYH_GLKit_01
//
//  Created by 杨昱航 on 2017/6/14.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import "ViewController.h"
#import "GLTestViewController.h"
@interface ViewController ()

@end

@implementation ViewController

//GLKit框架 (GLKit.framework)包含一组简化创建OpenGLES应用的Objective-C based 单元类。
//OpenGL ES:是苹果IOS设备上的用户界面和图形绘制能力的基础。“ES”代表嵌入式系统（Embeded System）。
/*
 3D渲染
 图形处理单元（GPU）就是能结合集合、颜色、灯光和其他数据而产生的一个屏幕图像的硬件组件。屏幕只有2维，因此显示3D数据的技巧就在于产生能够迷惑眼睛使其看到丢失的第三维的一个图像。用3D数据生成一个2D图像的过程就叫做渲染。在计算机上显示的图片是由矩形的颜色点组成的，这些矩形的颜色点叫做像素。如果通过放大镜仔细观察显示器，你会发现每个像素都是由红、绿、蓝3个元素组成的。
 */
/*
 为图形处理器提供数据
 程序会保存3D场景数据到硬件随机存储器在RAM中。嵌入式中央处理单元有专门为其分配的RAM。
 OpenGL ES是一种软件技术。OpenGL ES部分运行在CPU上，部分运行在GPU上。
 OpenGL ES横跨在两个处理器之间，协调两个内存区域之间的数据交换。
 缓存，提供数据的最好方式。OpenGL ES为两个内存区域间的数据交换定义了缓存的概念。缓存的概念是指GPU图形处理器能够控制和管理的连续的RAM。通过控制独立的缓存，GPU就能尽可能以最有效的方式读写内存。图形处理器把它处理大量数据的能力异步同时地应用到缓存上，这意味着在GPU使用缓存中的数据工作的同时，运行在CPU上的程序可以继续执行。
 几乎所有程序提供给GPU的数据都应该放入缓存中。缓存存储的到底是几何数据、颜色。灯光效果，还是其他的信息并不重要。为缓存提供数据有以下7个步骤
 */

/*
 1.生产（Generate）-请求OpenGL ES为图形处理器控制的缓存生产一个独一无二的额标识符。
 glGenBuffers(<#GLsizei n#>, <#GLuint *buffers#>)
 
 2.绑定（Bind）-告诉OpenGL ES为接下来的运算使用一个缓存。
 glBindBuffer(<#GLenum target#>, <#GLuint buffer#>)
 
 3.缓存数据（Buffer Data）-让OpenGL ES为当前绑定的缓存分配并初始化足够的连续内存（通常是从CPU控制的内存复制数据到分配的内存）。
 glBufferData(<#GLenum target#>, <#GLsizeiptr size#>, <#const GLvoid *data#>, <#GLenum usage#>)
 
 4.启用（Enable）或者禁用（Disable）-告诉OpenGL ES在接下来的渲染中是否使用缓存中的数据。
 glEnableVertexAttribArray(<#GLuint index#>)或者glDisableVertexAttribArray(<#GLuint index#>)
 
 5.设置指针（Set Pointers）-告诉OpenGL ES在缓存中的数据的类型和所有需要的访问的数据的内存偏移值。
 glVertexAttribPointer(<#GLuint indx#>, <#GLint size#>, <#GLenum type#>, <#GLboolean normalized#>, <#GLsizei stride#>, <#const GLvoid *ptr#>)
 
 6.绘图（Draw）-告诉OpenGL ES使用当前绑定并启用的缓存中的数据渲染整个场景或者摸个场景中的一部分。
 glDrawArrays(<#GLenum mode#>, <#GLint first#>, <#GLsizei count#>)或者glDrawElements(<#GLenum mode#>, <#GLsizei count#>, <#GLenum type#>, <#const GLvoid *indices#>)
 
 7.删除（Delete）-告诉OpenGL ES删除以前生成的缓存并释放相关的资源。
 glDeleteBuffers(<#GLsizei n#>, <#const GLuint *buffers#>)
 */


/*
 帧缓存:
 GPU需要知道应该在内存的哪个位置存储渲染出来的2D图像像素数据。就像为GPU提供数据的缓存一样，接受渲染结果的缓冲区叫做帧缓存（Frame Buffer）。程序会像任何其他种类的缓存一样生成、绑定、删除帧缓存。但是帧缓存不需要初始化，因为渲染指令会在适当的时候替换缓存的内容。帧缓存会在被绑定的时候隐式开启，同时OpenGL ES会自动根据特定平台的硬件配置和功能来设置数据的类型和偏移。
 可以同时存在很多帧缓存，并且可以通过OpenGL ES让GPU吧渲染结果存储到任意数量的帧缓存中。但是，屏幕显示像素要受到保存在前帧缓存（front frame buffer）的特定帧缓存中的像素颜色元素的控制。而程序和操作系统很少会直接渲染到前帧缓存中，因为那样会让用户看到正在渲染中的还没有渲染完的图像。相反，程序和操作系统会把渲染结构保存到包括后帧缓存（back frame buffer）在内的其他帧缓存中。当渲染后的后帧缓存包含一个完成的图像时，前帧缓存和后帧缓存几乎会瞬间切换。后帧缓存，会变成新的前帧缓存，同时旧的前帧缓存会变成后帧缓存。
 */

/*
 OpenGL ES的上下文:
 用于配置OpenGL ES的保存在特定平台的软件数据结构中的信息会被封装到一个OpenGL ES上下文中（context）。上下文中的信息可能会被保存在CPU所控制的内存中，也有可能保存在GPU所控制的内存中。OpenGL ES会按需在两个内存区域之间复制信息，知道何时发生复制有助于程序的优化。
 OpenGL ES上下文会跟踪用于渲染的帧缓存。上下文还会跟踪勇于几何书籍、颜色等的缓存。上下文决定是否使用某些功能，比如纹理和灯光，上下文还会为渲染定义当前的坐标系统。
 */

/*
 坐标系:笛卡尔直角坐标系
 */

/*
 矢量:一个既有方向又有距离的一个量。顶点V1与顶点V2之间的矢量等于{V2.x-V1.x,V2.y-V1.y,V2.z-V1.z}。
 */

/*
 点、线、三角形:
 OpenGL ES使用顶点数据来定义点、线段和三角形。一个顶点会定义坐标系中的一个点的位置，两个顶点会定义一个线段，三个顶点会定义一个三角形。OPenGL ES只渲染顶点，线段和三角形。
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor=[UIColor redColor];
    
    [self performSelector:@selector(gotoVC) withObject:nil afterDelay:2];
}
-(void)gotoVC
{
    UIWindow * window=[[UIApplication sharedApplication].delegate window];
    window.rootViewController=[[GLTestViewController alloc]init];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
