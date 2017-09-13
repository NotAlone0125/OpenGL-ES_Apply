//
//  AGLTextureInfo.h
//  YYH_OpenGL ES04_GLKTextureLoader
//
//  Created by 杨昱航 on 2017/6/16.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

//OpenGL ES的纹理缓存与其他的缓存具有相同的步骤。首先使用glGenTextures()函数生成一个纹理缓存标识符；然后使用glBindTexture()函数将其绑定到当前上下文；接下来，通过使用glTexImage2D(）函数复制图像数据来初始化纹理缓存的内容

//AGLTextureLoader类不会出现在产品代码中，这里只是为了解析，消除关于GLKTextureLoader、Core Graphcis和OpenGL ES之间交互的神秘感。

//AGLTextureLoader类的接口和实现提供了GLKit提供的功能的一个子集。具体来说，GLKit的GLKTextureLoader类支持异步纹理加载，MIP贴图生成，以及比简单的2D平面更加吸引人的纹理缓存类型。AGLKTextureLoader只复制了一部分功能（YYH_GLKit_02Texture中实现的）。

//AGLTextureInfo是一个封装了纹理缓存的有用信息的简单类，例如相应的OpenGL ES纹理缓存的标识符以及纹理的图像尺寸。AGLKTextureLoader只声明了一个方法--“+textureWithCGImage:options:error:”。

//AGLKTextureLoader的实现展现了Core Graphics和OpenGL ES的整合，提供了与GLKit的GLKTextureLoader相似的功能。在“+textureWithCGImage:options:error:”方法中对于OpenGL ES函数的调用完成了标准的缓存管理步骤，包括生成、绑定和初始化一个新的纹理缓存

#pragma mark -AGLTextureInfo

@interface AGLTextureInfo : NSObject
{
    @private
    GLuint name;
    GLenum target;
    GLuint width;
    GLuint height;
}

@property(readonly)GLuint name;
@property(readonly)GLenum target;
@property(readonly)GLuint width;
@property(readonly)GLuint height;

@end

#pragma mark -AGLKTextureLoader

@interface AGLKTextureLoader : NSObject

+(AGLTextureInfo *)textureWithCGImage:(CGImageRef)cgImage options:(NSDictionary *)options error:(NSError **)outError;

@end
