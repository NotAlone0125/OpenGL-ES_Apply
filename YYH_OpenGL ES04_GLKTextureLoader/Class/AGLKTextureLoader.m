//
//  AGLTextureInfo.m
//  YYH_OpenGL ES04_GLKTextureLoader
//
//  Created by 杨昱航 on 2017/6/16.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import "AGLKTextureLoader.h"

typedef enum
{
    AGLK1 = 1,
    AGLK2 = 2,
    AGLK4 = 4,
    AGLK8 = 8,
    AGLK16 = 16,
    AGLK32 = 32,
    AGLK64 = 64,
    AGLK128 = 128,
    AGLK256 = 256,
    AGLK512 = 512,
    AGLK1024 = 1024,
}AGLKPowerOf2;

static AGLKPowerOf2 AGLKCalculatePowerOf2ForDimension(
                                                      GLuint dimension);

//+(AGLTextureInfo *)textureWithCGImage:(CGImageRef)cgImage options:(NSDictionary *)options error:(NSError *__autoreleasing *)outError使用AGLKDataWithResizedCGImageBytes来获取用于初始化纹理缓存的内容的字节，并且包含转换一个Core Graphics图像为OpenGL ES可用的合适字节的代码

//Core Graphics函数会把指定的cgImage拖入imageData提供的字节中。Core Graphics把cgImage拖入一个适当大小的Core Graphics上下文中，这个过程中的一个副作用是吧图像的尺寸调整为了2的幂。图像在被绘制的时候还被翻转了。翻转Y轴是必须的，因为Core Graphics是以远点在左上角同时Y轴向下增大的形式来实现ios 中的图片保存的。OpenGL ES的纹理坐标系会放置原点在左下角，同时Y值向上增大。翻转Y轴确保了图像字节拥有适用于纹理缓存的正确的方向。
static NSData * AGLKDataWithResizedCGImageBytes(
                                                CGImageRef cgImage,
                                                size_t *widthPtr,
                                                size_t *heightPtr)
{
    NSCParameterAssert(NULL!=cgImage);
    NSCParameterAssert(NULL!=widthPtr);
    NSCParameterAssert(NULL!=heightPtr);
    
    size_t originalWidth=CGImageGetWidth(cgImage);
    size_t originalHeight=CGImageGetHeight(cgImage);
    
    NSCAssert(0<originalWidth, @"invalid image width");
    NSCAssert(0<originalHeight, @"invalid image height");
    
    //Calculate the width and height of the new texture buffer,the new texture buffer will have power of 2 dimensions
    size_t width=AGLKCalculatePowerOf2ForDimension(originalWidth);
    size_t height=AGLKCalculatePowerOf2ForDimension(originalHeight);
    
    //allocate sufficient storage(分配足够的内存) for RGBA pixel color data with the power of 2 sizes specified
    NSMutableData * imageData=[NSMutableData dataWithLength:height*width*4];
    
    NSCAssert(nil!=imageData, @"unable to allocats image storage");
    
    //create a Core Graphics context that draws into the allocated bytes
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef cgContext=CGBitmapContextCreate([imageData mutableBytes], width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    
    //Flip the Core Graphics Y-axis for future drawing
    CGContextTranslateCTM(cgContext, 0, height);
    CGContextScaleCTM(cgContext, 1.0, -1.0);
    
    //draw the loaded image into the core Graphics context resizing as necessary
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height), cgImage);
    
    CGContextRelease(cgContext);
    
    *widthPtr=width;
    *heightPtr=height;
    
    return imageData;
};

@interface AGLTextureInfo (AGLKTextureLoader)

- (id)initWithName:(GLuint)aName
            target:(GLenum)aTarget
             width:(size_t)aWidth
            height:(size_t)aHeight;

@end


@implementation AGLTextureInfo (AGLKTextureLoader)

/////////////////////////////////////////////////////////////////
// This method is the designated initializer.
- (id)initWithName:(GLuint)aName
            target:(GLenum)aTarget
             width:(size_t)aWidth
            height:(size_t)aHeight
{
    if (nil != (self = [super init]))
    {
        name = aName;
        target = aTarget;
        width = aWidth;
        height = aHeight;
    }
    
    return self;
}

@end

@implementation AGLTextureInfo

@synthesize name;
@synthesize target;
@synthesize width;
@synthesize height;

@end

@implementation AGLKTextureLoader


+(AGLTextureInfo *)textureWithCGImage:(CGImageRef)cgImage options:(NSDictionary *)options error:(NSError *__autoreleasing *)outError
{
    //Get the bytes to be used when copying data into new texture buffer
    size_t width = 0;
    size_t height = 0;
    
    NSData * imageData=AGLKDataWithResizedCGImageBytes(cgImage, &width, &height);
    
    GLuint textureBufferID;
    
    //Generation，bind，and copy data into a new texTure buffer
    glGenTextures(1, &textureBufferID);
    glBindTexture(GL_TEXTURE_2D, textureBufferID);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, [imageData bytes]);
    /*
     glTexImage2D()是OpenGL ES标准中最复杂的函数之一。它复制图片像素的颜色数据到绑定的纹理缓存中。
     第一个参数是用于2D纹理的GL_TEXTURE_2D；
     第二个参数用于指定MIP贴图的初始细节级别，如果没有使用MIP贴图，第二个参数必须是0，如果开启了MIP贴图，使用第二个参数来明确地初始化每个细节级别，但是要小心，因为从全分辨率到只有一纹素；
     第三个参数是internalFormat，用于指定在纹理缓存内每个纹素需要保存的信息的数量。对于IOS设备来说，要么是GL_RGB，要么是GL_RGBA。GL_RGB为每个纹素保存红绿蓝三种颜色元素，GL_RGBA保存一个额外的用于指定每个纹素透明度的透明度元素。
     第四和第五个参数用于指定图像的宽度和高度。高度和宽度需要是2的幂。
     第六个参数border用来确定围绕纹理的纹素的一个边界的大小，但是在OpenGL ES中它总是被设置为0。
     第七个参数format用于指定初始化缓存所使用的图像数据中的每个像素所要保存的信息，这个参数应该总是与internalFormat一致，其他的OpenGL版本可能在format和internalFormat参数不一致时自动执行图像数据格式的转换。
     第八个参数用于指定缓存中的纹素数据所使用的位编码类型。
     最后一个参数是一个要被复制到绑定的纹理缓存中的图片的像素颜色数据的指针。
     */
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    AGLTextureInfo * result=[[AGLTextureInfo alloc]initWithName:textureBufferID target:GL_TEXTURE_2D width:width height:height];
    
    return result;
}




@end
