//
//  ViewController.m
//  YYH_GLKit_02Texture
//
//  Created by 杨昱航 on 2017/6/14.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import "ViewController.h"

typedef struct {
    GLKVector3 positionCoords;//GLKVector3类型的positionCoords
    GLKVector3 textureCoords;//GLKVector3类型的纹理坐标
}SceneVertex;

static const SceneVertex vertices[]={//前面三个数字是位置坐标，后面2个数字是纹理坐标
    {{-0.5f,-0.4f,0.0},{0.0f,0.0f}},
    {{0.5f,-0.4f,0.0},{1.0f,0.0f}},
    {{-0.5f,0.4f,0.0},{0.0f,1.0f}},
    {{0.5f,0.4f,0.0},{1.0f,1.0f}}
};

@interface ViewController ()

@end

@implementation ViewController

/*
 纹理：
 定义：纹理是一个用来保存图像的颜色元素值的OpenGL ES缓存。纹理可以使用任何图像，包括数目、面孔、砖块、云彩等。在纹理的缓存中保存的颜色值可能要耗费很多的内存。所有的嵌入式系统都为纹理设定了内存的最大尺寸的限制。由于嵌入式系统可用的内存相对较小，应尽量使用最小的图像来产生可以接受的渲染结果。
 
 纹素：当一个图像初始化一个纹理缓存后，在这个图像中的每个像素就变成了纹理中的一个纹素（texel）。与像素类似，纹素保存颜色数据。纹理坐标系有一个命名为S和T的2D轴。在一个纹理中无论有多少个纹素，纹理的尺寸永远是在S轴上从0.0到1.0，在T轴上从0.0到1.0。从一个1像素高的64像素宽的图像初始化来的纹理会沿着整个T轴有1个纹素，沿着S轴有64个像素。
 
 对齐纹理和几何图形：我们需要告诉OpenGL ES如何使用一个纹理来给几何图形对象着色。帧缓存中的像素位置叫做视口坐标。转换为视口坐标的结果是所有绘制的几何图形都被拉伸以适应屏幕的大小，在每个顶点的X、Y、Z坐标被转换成视口坐标后GPU会设置转换生成的图形内的每个像素的颜色。转换几何形状数据为帧缓存中的颜色像素的渲染步骤叫做点阵化，每个颜色像素叫做片元。当OpenGL ES没有使用纹理的时候，GPU会根据包含该片元的对象的顶点的颜色来计算每个片元的颜色。当设置使用纹理后，GPU会根据在当前绑定的纹理缓存中的纹素来计算每个片元的颜色。程序需要指定怎么对齐纹理和顶点，以便让GPU知道每个片元的颜色由哪些纹素决定。这个对齐又叫做映射，是通过扩展为每个顶点保存的数据来实现的：除了X、Y、Z坐标，每个顶点还给出了U和V坐标值。每个U坐标会映射顶点在视口中的最终位置到纹理中沿着S轴的一个位置。V坐标映射到T轴。
 
 纹理的取样模式：每个顶点的U和V坐标会附加到每个顶点在视口坐标中的最终位置然后GPU会根据计算出来的每个片元的U、V位置从绑定的纹理中选择纹素。这个选择过程叫做取样。取样会把纹理的S和T坐标系与每个渲染的三角形的顶点的U、V坐标匹配起来。
 */

-(void)descriptions
{
    //OpenGL ES支持多个不同的取样模式：一个拥有大量纹素的纹理被映射到帧缓存内的一个只覆盖几个像素的三角形中，这种情况会在任何时间发生。相反的情况也会发生。一个包含少量纹素的纹理可能会被映射到一个帧缓存中产生很多个片元的三角形。程序会使用如下的glTexParameteri()函数来配置每个绑定的纹理，以便使OpenGL ES知道怎么处理可用纹素的数量与需要被着色的片元的数量之间的不匹配。
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);//告诉OpenGL ES无论何时出现多个纹素对应一个片元时，与片元的U、V坐标最接近的纹素颜色会被取样。
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);//告诉OpenGL ES无论何时出现多个纹素对应一个片元时，从相配的多个像素中取样颜色，然后使用线性内插法来混合这些颜色以得到片元的颜色。
 
    //GL_TEXTURE_MAG_FILTER参数用于没有足够纹素来唯一性的映射一个或者多个纹素到每个片元时配置取样
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);//会有一个放大纹理的效果，并让它模糊的出现在渲染的三角形上
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);//仅仅会拾取与片元的U、V位置接近的纹素的颜色，并放大纹理，这会使它有点像素化地出现在渲染的三角形上
    
    
    //除了减小和放大过滤选项，当U、V坐标值小于0或者大于1时，程序会指定要发生什么。有两个选择，要么尽可能多的重复纹理以填满映射到几何图形的整个U、V区域，要么每当片元的U、V坐标的值超出纹理的S、T坐标系的范围时，取样纹理边缘的纹素。纹理的循环模式是为S和T分别设置的，参考代码如下：
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);//取样纹理边缘的纹素
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);//重复纹理填满
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);//取样纹理边缘的纹素
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);//重复纹理填满
    
    
    //MIP贴图：是与取样密切相关的。内存存取是现代图形处理的薄弱环节，当有多个纹素对应一个片元的时候，线性取样会导致GPU仅仅为了计算一个片元的最终颜色而读取多个纹素的颜色值。MIP贴图是一个为一个纹理储存多个细节级别的技术。高细节的纹理会沿着S轴和T轴存储很多纹素。低细节的纹理沿着每个轴存储很少的纹素。最低细节的纹理只保存一个纹素。多个细节级别增加了在S、T轴上的纹素和每个片元的U、V坐标之间有紧密的对应关系的可能性。当存在一个紧密的对应关系时，GPU会减少取样纹素的数量，进而会减少内存访问的次数。使用MIP贴图通常会通过减少GPU取样的数量来提高渲染的性能，但是MIP贴图使每个纹理所需要的内存增加了1/3。
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    GLKView * view=(GLKView *)self.view;
    
    view.context=[[AGLKContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [AGLKContext setCurrentContext:view.context];
    
    self.baseEffect=[[GLKBaseEffect alloc]init];
    self.baseEffect.useConstantColor=GL_TRUE;
    self.baseEffect.constantColor=GLKVector4Make(1.0f,//red
                                                 1.0f,//green
                                                 1.0f,//blue
                                                 1.0f);
    ((AGLKContext *)view.context).clearColor=GLKVector4Make(0.0f, // Red
                                                            0.0f, // Green
                                                            0.0f, // Blue
                                                            1.0f);// Alpha
    
    /*1、为缓存生成一个独一无二的标识符
     *2、为接下来的应用绑定缓存
     *3、复制数据到缓存中
     */
    self.vertexBuffer = [[AGLKVertexAttribArrayBuffer alloc] initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(vertices)/sizeof(SceneVertex) data:vertices usage:GL_STATIC_DRAW];
    
    //GLKit提供了GLKtextureLoader类，这个类将一个纹理图像加载到一个OpenGL ES纹理缓存中
    CGImageRef imageRef=[[UIImage imageNamed:@"Default"] CGImage];
    GLKTextureInfo * info=[GLKTextureLoader textureWithCGImage:imageRef options:nil error:NULL];//接受一个CGImageRef并创建一个新的包含CGImageRef的像素数据的OpenGL ES纹理缓存，options参数接受一个存储了用于指定GLKTextureLoader怎么解析加载的图像数据的键值对的NSDictionary。可用选项之一是指示GLKTextureLoader为加载的图像生成MIP贴图。
    
    self.baseEffect.texture2d0.name=info.name;//设置baseEffect的texture2d0属性和使用一个新的纹理缓存。GLKTextureInfo类封装了与刚创建的纹理缓存相关的信息，包含他的尺寸、是否包含MIP贴图、OpenGL ES标识符、名字以及用于纹理的OpenGL ES目标等。
    self.baseEffect.texture2d0.target = info.target;
}


#pragma mark 这两个方法每帧都执行一次（循环执行），执行频率与屏幕刷新率相同。第一次循环时，先调用“glkView”再调用“update”。一般，将场景数据变化放在“update”中，而渲染代码则放在“glkView”中
- (void)update{
    
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
    [self.baseEffect prepareToDraw];
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    /*4、启动顶点缓存渲染操作
     *5、告诉OpenGL ES顶点数据在哪里，以及解释为每个顶点保存的数据
     */
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, positionCoords) shouldEnable:YES];
    
    /*4、启动纹理缓存渲染操作
     *5、告诉OpenGL ES纹理数据在哪里，以及解释为每个纹理保存的数据
     */
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribTexCoord0 numberOfCoordinates:2 attribOffset:offsetof(SceneVertex, textureCoords) shouldEnable:YES];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLE_STRIP starVertexIndex:0 numberOfVertices:4];
}

-(void)dealloc
{
    GLKView * view=(GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    self.vertexBuffer=nil;
    
    ((GLKView *)self.vertexBuffer).context=nil;
    [EAGLContext setCurrentContext:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
