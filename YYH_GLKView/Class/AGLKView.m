//
//  AGLKView.m
//  YYH_GLKView
//
//  Created by 杨昱航 on 2017/6/15.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import "AGLKView.h"

#import <QuartzCore/QuartzCore.h>

//AGLKView的时间比较简单易懂，但重写了来自UIView的多个方法并添加了一些用于支持OpenGL ES绘图的方法。
@implementation AGLKView

@synthesize delegate;
@synthesize context;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark Init

+(Class)layerClass
{
    //告知需要使用一个CAEAGLLayer类的实例，而不是原来的CALayer。CAEAGLLayer是Core Animation提供的标准层类之一。CAEAGLLayer会与一个OpenGL ES的帧缓存共享它的像素颜色仓库。
    return [CAEAGLLayer class];
}

//
-(id)initWithFrame:(CGRect)frame context:(EAGLContext *)aContext
{
    if (self=[super initWithFrame:frame])
    {
        //初始化视图的Core Animation层的本地指针
        CAEAGLLayer * eaglLayer=(CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];
        
        self.context=context;
    }
    return self;
}
//Coaoa Touch会自动调用"-initWithCoder:"方法，这是反归档先前归档入一个文件的对象的过程的一部分。在这个例子中使用的AGLKView实例会自动地从应用的storyboard文件中加载（又叫做反归档）。
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super initWithCoder:aDecoder])
    {
        CAEAGLLayer * eaglLayer=(CAEAGLLayer *)self.layer;
        
        eaglLayer.drawableProperties=[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO],kEAGLDrawablePropertyRetainedBacking,kEAGLColorFormatRGBA8,kEAGLDrawablePropertyColorFormat,nil];//第一个键值对的含义为不使用“保留背景”，意思是告诉Core Animation在层的任何部分需要再屏幕上显示的时候都要绘制整个层的内容；RGBA8颜色格式是告诉Core Animation用8位来保存层内的每个像素的每个颜色元素的值。换句话说，这段代码是告诉Core Animation不要试图保留任何以前绘制的图像留作以后重用。
        
    }
    return self;
}

#pragma mark 访问器

//两个手动实现的访问器方法用于设置和返回视图的特定于平台的OpenGL ES上下文。因为AGLKView实例需要创建和配置一个帧缓存和一个像素颜色渲染缓存来与视图的Core Animation层一起使用，所以设置上下文会引起一些副作用。由于上下文保存缓存，因此修改视图的上下文会导致先前创建的所有缓存全部失效，并需要创建和配置新的缓存。
//下面的代码中，创建帧缓存和渲染缓存会遵循一些适用于其他类型的缓存的相同的步骤，包括顶点数组中的缓存。一个新的步骤会调用glFramebufferRenderbuffer（）函数来配置当前绑定的帧缓存以便在colorRenderBuffer中保存渲染的像素颜色。
-(void)setContext:(EAGLContext *)aContext
{
    if (context!=aContext)
    {
        [EAGLContext setCurrentContext:context];
        if (0!=defaultFrameBuffer) {
            glDeleteFramebuffers(1, &defaultFrameBuffer);
            defaultFrameBuffer=0;
        }
        if (0!=colorRenderBuffer) {
            glDeleteRenderbuffers(1, &colorRenderBuffer);
            colorRenderBuffer=0;
        }
        
        context=aContext;
        
        if (nil!=context) {
            context=aContext;
            [EAGLContext setCurrentContext:context];
            
            glGenFramebuffers(1, &defaultFrameBuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, defaultFrameBuffer);
            
            glGenRenderbuffers(1, &colorRenderBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
            
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer);
            
        }
    }
}
//下面的“-disPlay”方法设置视图的上下文为当前上下文，告诉OpenGL ES让渲染天猫整个缓存，调用视图的"-drawRect"方法来实现OpenGL ES函数进行真正的绘图，然后让上下文调整外观并使用Core Animation合成器把帧缓存的像素颜色渲染缓存与其他相关层混合起来。
-(void)display
{
    [EAGLContext setCurrentContext:self.context];
    
    //glViewport()函数可以控制渲染至缓存的子集，但是在这个例子中使用的是整个帧缓存
    glViewport(0, 0, sizeof(self.drawableWidth), sizeof(self.drawableHeight));
    
    [self drawRect:[self bounds]];
}

//如果视图的委托属性不是nil，“-drawRect:”方法会调用委托的“glkView:drawInRect:”方法。没有委托，AGLKView什么都不会绘制。AGLKView的子类可以通过重写继承的"-drawRect"实现来绘图，即使是没有指定委托。”-glkView：drawInRect：“的参数是一个要被绘制的视图和一个覆盖整个视图范围的矩形。
-(void)drawRect:(CGRect)rect
{
    if (self.delegate) {
        [self.delegate glkView:self drawInRect:self.bounds];
    }
}
//任何在接收到视图重新调整大小的消息时，Cocoa Touch都会调用下面的”-(void)layoutSubviews“方法，视图会自动地调整相关层的尺寸。上下文的”renderbufferStorage:framDrawable:“方法会调整视图的缓存的尺寸以匹配层的新尺寸。
-(void)layoutSubviews
{
    CAEAGLLayer * eaglLayer=(CAEAGLLayer *)self.layer;
    
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer);
    
    GLenum status=glCheckFramebufferStatus(GL_RENDERBUFFER);
    
    if (status!=GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"fail to make complete frame buffer object %x",status);
    }
}

//下面两个访问器被实现用来通过OpenGL ES的glGetRenderbufferParameteriv()方法获取和返回当前上下文的帧缓存的像素颜色渲染缓存的尺寸。
-(NSInteger)drawableWidth
{
    GLint backingWidth;
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    
    return (NSInteger)backingWidth;
}
-(NSInteger)drawableHeight
{
    GLint backingHeight;
    
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    return (NSInteger)backingHeight;
}


-(void)dealloc
{
    if ([EAGLContext currentContext]==context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    
    context=nil;
}













@end
