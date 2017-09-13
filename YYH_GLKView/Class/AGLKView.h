//
//  AGLKView.h
//  YYH_GLKView
//
//  Created by 杨昱航 on 2017/6/15.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;

@protocol AGLKViewDelegate;

@interface AGLKView : UIView
{
    EAGLContext * context;
    GLuint defaultFrameBuffer;
    GLuint colorRenderBuffer;
    GLint drawableWidth;
    GLint drawableHeight;
}
@property(nonatomic,weak)id<AGLKViewDelegate>delegate;

@property(nonatomic,retain)EAGLContext * context;

@property(nonatomic,readonly)NSInteger drawableWidth;
@property(nonatomic,readonly)NSInteger drawableHeight;

-(void)display;


@end


@protocol AGLKViewDelegate <NSObject>

@required

-(void)glkView:(AGLKView *)view drawInRect:(CGRect)rect;

@end





