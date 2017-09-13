//
//  GLTestViewController.m
//  YYH_GLKit_01
//
//  Created by 杨昱航 on 2017/6/14.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import "GLTestViewController.h"

//SceneVertex是一个C的结构体，用来保存一个GLKVector3类型的成员positionCoords。GLKit的GLKVector3保存了3个坐标：X、Y、Z。
typedef struct {
    GLKVector3 positionCoords;
}SceneVertex;

static const SceneVertex vertices[]={
    {{-0.5f,-0.5f,0.0}},//lower left corner
    {{0.5f,-0.5f,0.0}},//lower right corner
    {{-0.5f,0.5f,0.0}}//upper left corner
};

@interface   GLTestViewController ()

@end

@implementation GLTestViewController
/*
 GLKit是苹果iOS 5引入的一个为简化OpenGL ES的使用的框架，它为OpenGL ES的使用提供了相关的类和函数，GLKit是Cocoa Touch以及多个其他的框架（包含UIKit）的一部分。而GLKView和GLKViewController类名字中的GLK前缀表明这些类是GLKit框架的一部分。
 GLKViewController类是支持OpenGL ES特有的行为和动画时的UIViewController的内建子类。
 GLKView是Cocoa Touch UIView类的内建子类。GLKView简化了通过用Core Animation层来自动创建并管理帧缓存和渲染缓存共享内存所需要做的工作。GLKView相关的GLKViewController实例是视图的委托并接收当视图需要重绘时的消息。
 */


-(void)description{
    //viewDidLoad为OpenGL ES提供三角形的顶点数据。此方法会将它继承的view属性的值转换成GLKView类型。类似ViewController的GLKViewController的子类只能与GLView实例或者GLView的子类的实例一起工作。
    
    /*
     OpenGL ES的上下文不仅会保存OpenGL ES的状态，还会控制GPU去执行渲染运算。在这里分配并初始化一个内建的EAGLContext类的实例，这个实例会封装一个特定于某个平台的OpenGL ES上下文，在任何其他的OpenGL ES配置或者渲染发生之前，应用的GLView实例的上下文属性都要设置为当前。EAGLContext实例既支持OpenGL ES1.1又支持OpenGL ES2.0和3.0。EAGLContext的方法“+setCurrentContext：”会为接下来的OpenGL ES运算设置将会用到的上下文，而“-initWithAPI：”方法传入一个kEAGLRenderingAPIOpenGLES2常量将它初始化为OpenGL ES 2.0。
     
     baseEffect属性为一个新分配并初始化的GLKBaseEffect类型的实例，useConstantColor属性说明使用恒定不变的颜色，而constantColor定义了这种恒定颜色的颜色值。GLKVector4Make是GLKit中定义的用于保存4个颜色值的C数据结构体。
     
     glClearColor()函数设置当前OpenGL ES的上下文的“清除颜色”为不透明白色，清除颜色由RGBA颜色元素值组成，用于在上下文的帧缓存被清除时初始化每个像素的颜色值。
     */
    
    //上一篇文章介绍了用于CPU和GPU控制的内存之间交换数据的缓存的概念。用于定义要缓存的三角形的顶点位置数据必须要发送到GPU来渲染。创建并使用一个用于保存顶点数据的顶点数组属性数组缓存。前三步骤如下：
    
    //为缓存生成一个独一无二的标识符:
    //参数1：要生成缓存标识符的数量
    //参数2：指向生成的标识符的内存保存位置的指针
    glGenBuffers(1, &vertexBufferID);
    
    //为接下来的运算绑定缓存
    //参数1：用于指定要绑定哪一种类型的缓存，OPenGL ES2.0对于glbindBuffer()的实现只支持两种类型的缓存:GL_ARRAY_BUFFER：顶点缓冲区对象；GL_ELEMENT_ARRAY_BUFFER：顶点索引缓冲区对象
    //参数2：要绑定缓存的标识符
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    
    //复制数据到缓存中
    //参数1：指定要更新当前上下文中所绑定的是哪一种缓存
    //参数2：指定要复制这个缓存字节的数量
    //参数3：复制的字节的地址
    //参数4：缓存在未来的运算中可能将会被怎样使用:GL_STATIC_DRAW提示会告诉上下文，缓存中的内容适合复制到GPU控制的内存，因为很少对其修改;GL_DYNAMIC_DRAW会告诉上下文，缓存内的数据会频繁改变，同时提示OpenGL ES以不同的方式来处理缓存的存储
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    GLKView * view=(GLKView *)self.view;
    //使用NSAssert()函数的一个运行时检查会验证self.view是否为正确的类型
    NSAssert([view isKindOfClass:[GLKView class]],  @"viewcontroller’s view is not a GLKView");
    
    view.context=[[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];//分配一个新的EAGLContext的实例，并将它初始化为OpenGL ES 2.0
    [EAGLContext setCurrentContext:view.context];//在任何其他的OpenGL ES配置或者渲染之前，应用的GLKview实例的上下文属性都要设置为当前
    
    self.baseEffect=[[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor=GL_TRUE;
    self.baseEffect.constantColor=GLKVector4Make(0.4f, 0.6f, 0.2, 1.0f);
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);//设置当前OpenGL ES的上下文的“清除颜色”为不透明白色
    
    glGenBuffers(1, &vertexBufferID);
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferID);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
}
//这个方法每帧都执行一次(循环执行)，执行频率与屏幕刷新率相同，iPhone屏幕的刷新频率是60Hz
-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    /*
     每当一个GLKView实例需要被重绘时，它都会让保存在视图的上下文属性中的OpenGL ES上下文成为当前上下文。如果需要的话，GLKView实例会绑定一个与Core Animation层分享的帧缓存，执行其他的标准的OPenGL ES配置，并发送一个消息来调用ViewController的--glkView: drawInRect:方法，-glkView: drawInRect:是GLKView的委托方法。
     */
    
    //委托方法的实现[self.baseEffect prepareToDraw]，告诉baseEffect准备好当前的OpenGL ES的上下文，以便为使用baseEffect生成的属性和Shading Language程序的绘图做好准备。
    [self.baseEffect prepareToDraw];
    
    //glClear()来设置当前绑定的帧缓存的像素颜色渲染缓存中的每一个像素的颜色为前面使用glClearColor()函数设定的值。glClear()函数会有效的设置帧缓存中的每一个像素的颜色为背景色。
    glClear(GL_COLOR_BUFFER_BIT);
    
    
    //启动顶点缓存渲染操作
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    
    
    /*
     使用缓存的前三步已经在- viewDidLoad方法中被执行了。-glkView: drawInRect:方法会执行剩下的几个步骤：
    1.启动：通过glEnableVertexAttribArray()来启动顶点缓存渲染操作。OpenGL ES 所支持的每一个渲染操作都可以单独的使用保存在当前OpenGL ES上下文中的设置来开启或关闭。
    2.设置指针：glVertexAttribPointer()函数会告诉OpenGL ES顶点数据在哪里，以及怎么解释为每个顶点保存的数据。
    3.绘图:通过调用glDrawArrays()来执行绘图。
    */
    
    /*
     参数1：指示当前绑定的缓存包含每个顶点的位置信息
     参数2：指示每个位置有三个部分
     参数3：告诉OpenGL ES每个部分都保存为一个浮点类型的值
     参数4：告诉OPenGL ES小数点固定数据是否可以被改变
     参数5：叫做步幅，他指定了每个顶点的保存需要多少个字节
     参数6：告诉OpenGL ES可以从当前绑定的顶点缓存的位置访问顶点数据
     */
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL);
    
    /*
     参数1：告诉GPU怎么处理在绑定的顶点缓存内的顶点数据
     GL_POINTS //把每一个顶点作为一个点进行处理，顶点n即定义了点n，共绘制N个点
     GL_LINES //把每一个顶点作为一个独立的线段，顶点2n－1和2n之间共定义了n条线段，总共绘制N/2条线段
     GL_LINE_LOOP //绘制从第一个顶点到最后一个顶点依次相连的一组线段，然后最后一个顶点和第一个顶点相连，第n和n+1个顶点定义了线段n，总共绘制n条线段
     GL_LINE_STRIP //绘制从第一个顶点到最后一个顶点依次相连的一组线段，第n和n+1个顶点定义了线段n，总共绘制n－1条线段
     GL_TRIANGLES //把每个顶点作为一个独立的三角形，顶点3n－2、3n－1和3n定义了第n个三角形，总共绘制N/3个三角形
     GL_TRIANGLE_STRIP //绘制一组相连的四边形。每个四边形是由一对顶点及其后给定的一对顶点共同确定的。顶点2n－1、2n、2n+2和2n+1定义了第n个四边形，总共绘制N/2-1个四边形
     GL_TRIANGLE_FAN //绘制一组相连的三角形，三角形是由第一个顶点及其后给定的顶点确定，顶点1、n+1和n+2定义了第n个三角形，总共绘制N-2个三角形
     参数2：需要渲染的第一个顶点
     参数3：需要渲染的顶点的个数
     */
    glDrawArrays(GL_TRIANGLES, 0, 3);
    
}

//ViewController实现的最后一个方法是-(void)dealloc{}，在这个函数里删除不再需要的顶点缓存和上下文。设置vertexBufferID为0避免了在对应的缓存被删除后还使用其无效的标识符。设置视图的上下文属性为nil并设置当前的上下文为nil，以便让Cocoa Touch收回所有上下文使用的内存和其他资源。
-(void)dealloc
{
    GLKView * view=(GLKView *)self.view;
    [EAGLContext setCurrentContext:view.context];
    
    if (0!=vertexBufferID)
    {
        glDeleteBuffers(1, &vertexBufferID);
        //设置vertexBufferID为0避免了在对应的缓存被删除后还使用其无效的标识符。
        vertexBufferID = 0;
    }
    
    //设置视图的上下文属性为nil并设置当前的上下文为nil，以便让Cocoa Touch收回所有上下文使用的内存和其他资源
    ((GLKView *)self.view).context=nil;
    [EAGLContext setCurrentContext:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
