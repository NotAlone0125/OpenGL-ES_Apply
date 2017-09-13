//
//  ViewController.m
//  YYH_OpenGL ES05_灯光_01
//
//  Created by 杨昱航 on 2017/6/26.
//  Copyright © 2017年 杨昱航. All rights reserved.
//

#import "ViewController.h"
/////////////////////////////////////////////////////////////////
// This data type is used to store information for each vertex
typedef struct {
    GLKVector3  position;
    GLKVector3  normal;
}SceneVertex;

/////////////////////////////////////////////////////////////////
// This data type is used to store information for triangles
typedef struct {
    SceneVertex vertices[3];
}SceneTriangle;

/////////////////////////////////////////////////////////////////
// Define the positions and normal vectors of each vertex in the
// example.
static const SceneVertex vertexA =
{{-0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexB =
{{-0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexC =
{{-0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexD =
{{ 0.0,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexE =
{{ 0.0,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexF =
{{ 0.0, -0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexG =
{{ 0.5,  0.5, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexH =
{{ 0.5,  0.0, -0.5}, {0.0, 0.0, 1.0}};
static const SceneVertex vertexI =
{{ 0.5, -0.5, -0.5}, {0.0, 0.0, 1.0}};

/////////////////////////////////////////////////////////////////
// Forward function declarations
static SceneTriangle SceneTriangleMake(
                                       const SceneVertex vertexA,
                                       const SceneVertex vertexB,
                                       const SceneVertex vertexC);

//光线计算依赖于表面法向量。可以为任何一个三角形计算出一个法向量：法向量的方向垂直于一个三角形的平面并且法向量可以使用定义三角形的任意两个矢量的矢量积计算出来。法向量也是单位向量，这意味着一个法向量的大小（也成为长度）总是1.0。
//任何矢量都可以转换成一个单位向量，通过用这个矢量的长度除以这个矢量的每个分量。结果是一个与原先的矢量方向相同的并且长度等于1.0的新矢量。因此，为了计算一个法向量，首先需要计算矢量积向量，然后用这个矢量积向量的长度除以矢量积的每个分量。这个操作是如此的常见以至于转换矢量为单位矢量通常被称为“标准化”操作。
//如下代码来计算法向量:
GLKVector3 SecneVector3UnitNormal(const GLKVector3 vectorA,const GLKVector3 vectorB)
{
    //GLKVector3Normalize返回一个与矢量方向相同但是大小等于1.0的单位向量
    return GLKVector3Normalize(GLKVector3CrossProduct(vectorA, vectorB));
    
    //矢量积是用GLKit的GLKVector3.h头文件的一个内联函数(GLKVector3CrossProduct)来计算的。
    //如下代码来计算向量积:
    //GLKVector3 GLKVector3CrossProduct(GLKVector3 vectorA, GLKVector3 vectorB)
    //{
    //    GLKVector3 result={
    //        vectorA.y*vectorB.z-vectorA.z*vectorB.y,
    //        vectorA.z*vectorB.x-vectorA.x*vectorB.z,
    //        vectorA.x*vectorB.y-vectorA.y*vectorB.x,
    //    };
    //    
    //    return result;
    //}
}
//GLKVector3Length(<#GLKVector3 vector#>)内联函数实现原理，得知矢量的长度
GLfloat SecneVector3Length(const GLKVector3 vectorA)
{
    GLfloat length=0.0f;
    
    GLfloat lengthSquared=(vectorA.x+vectorA.x)+(vectorA.y+vectorA.y)+(vectorA.z+vectorA.z);
    
    if (FLT_EPSILON<lengthSquared) {
        length=sqrt(lengthSquared);
    }
    
    return length;
}
//GLKVector3Normalize内联函数实现原理
GLKVector3 SeneVector3Normalise(GLKVector3 vectorA)
{
    const float length=SecneVector3Length(vectorA);
    
    float oneOverLength=0.0f;
    
    if (FLT_EPSILON<length)
    {
        oneOverLength=1.0f/length;
    }
    
    GLKVector3 result={
        vectorA.x*oneOverLength,
        vectorA.y*oneOverLength,
        vectorA.z*oneOverLength
    };
    
    return result;
}

/////////////////////////////////////////////////////////////////
// The scene to be rendered is composed of 8 triangles. There are
// 4 triangles in the pyramid itself and othe 4 horizontal
// triangles represent a base for teh pyramid.
#define NUM_FACES (8)

/////////////////////////////////////////////////////////////////
// 48 vertices are needed to draw all of the normal vectors:
//    8 triangles * 3 vertices per triangle = 24 vertices
//    24 vertices * 1 normal vector per vertex * 2 vertices to
//       draw each normal vector = 48 vertices
#define NUM_NORMAL_LINE_VERTS (48)

/////////////////////////////////////////////////////////////////
// 50 vertices are needed to draw all of the normal vectors
// and the light direction vector:
//    8 triangles * 3 vertices per triangle = 24 vertices
//    24 vertices * 1 normal vector per vertex * 2 vertices to
//       draw each normal vector = 48 vertices
//    plus 2 vertices to draw the light direction = 50
#define NUM_LINE_VERTS (NUM_NORMAL_LINE_VERTS + 2)

static GLKVector3 SceneTriangleFaceNormal(
                                          const SceneTriangle triangle);

static void SceneTrianglesUpdateFaceNormals(
                                            SceneTriangle someTriangles[NUM_FACES]);

static void SceneTrianglesUpdateVertexNormals(
                                              SceneTriangle someTriangles[NUM_FACES]);

static  void SceneTrianglesNormalLinesUpdate(
                                             const SceneTriangle someTriangles[NUM_FACES],
                                             GLKVector3 lightPosition,
                                             GLKVector3 someNormalLineVertices[NUM_LINE_VERTS]);

static  GLKVector3 SceneVector3UnitNormal(
                                          const GLKVector3 vectorA, 
                                          const GLKVector3 vectorB);

@interface ViewController ()
{
    SceneTriangle triangles[8];
}
@end

@implementation ViewController

@synthesize baseEffect;
@synthesize extraEffect;
@synthesize vertexBuffer;
@synthesize extraBuffer;
@synthesize centerVertexHeight;
@synthesize shouldUseFaceNormals;
@synthesize shouldDrawNormals;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    // Verify the type of view created automatically by the
    // Interface Builder storyboard
    GLKView *view = (GLKView *)self.view;
    NSAssert([view isKindOfClass:[GLKView class]],
             @"View controller's view is not a GLKView");
    
    // Create an OpenGL ES 2.0 context and provide it to the
    // view
    view.context = [[AGLKContext alloc]
                    initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    // Make the new context current
    [AGLKContext setCurrentContext:view.context];
    
    
    //GLKBaseEffect类最多支持三个命名为light1，light0，light2的模拟灯光。每个灯光至少有一个位置，一个环境颜色，一个漫反射颜色和一个镜面反射颜色。
    //开启灯光
    self.baseEffect=[[GLKBaseEffect alloc]init];
    self.baseEffect.light0.enabled=GL_TRUE;
    self.baseEffect.light0.diffuseColor=GLKVector4Make(0.7f, 0.7f, 0.7f, 1.0f);
    //第四个元素代表三个光源的位置是否是同一个方向（0代表同一个方向）。
    self.baseEffect.light0.position=GLKVector4Make(1.0f, 1.0f, 0.5f, 0.0f);
    
    
    extraEffect=[[GLKBaseEffect alloc]init];
    self.extraEffect.useConstantColor=GL_TRUE;
    self.extraEffect.constantColor=GLKVector4Make(0.0f, 1.0f, 0.0f, 1.0f);
    
    //旋转场景并定位以更容易看到三角锥的高度变化
    {
        GLKMatrix4 modelViewMatrix=GLKMatrix4MakeRotation(GLKMathDegreesToRadians(-60.0f), 1.0f, 0.0f, 0.0f);
        modelViewMatrix=GLKMatrix4Rotate(modelViewMatrix, GLKMathDegreesToRadians(-30.0f), 0.0f, 0.0f, 1.0f);
        self.baseEffect.transform.modelviewMatrix=modelViewMatrix;
        self.extraEffect.transform.modelviewMatrix=modelViewMatrix;
    }
    
    //三角形存储在一个顶点属性数组缓存中以供GPU使用
    triangles[0]=SceneTriangleMake(vertexA,vertexB,vertexD);
    triangles[1]=SceneTriangleMake(vertexB,vertexC,vertexF);
    triangles[2]=SceneTriangleMake(vertexD,vertexB,vertexE);
    triangles[3]=SceneTriangleMake(vertexE,vertexB,vertexF);
    triangles[4]=SceneTriangleMake(vertexD,vertexE,vertexH);
    triangles[5]=SceneTriangleMake(vertexE,vertexF,vertexH);
    triangles[6]=SceneTriangleMake(vertexG,vertexD,vertexH);
    triangles[7]=SceneTriangleMake(vertexH,vertexF,vertexI);
    
    self.vertexBuffer=[[AGLKVertexAttribArrayBuffer alloc]initWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles usage:GL_DYNAMIC_DRAW];
    
    //开启和配置灯光之后，要做的就是为灯光照射的图形的每一个顶点提供法向量
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self.baseEffect prepareToDraw];
    
    [(AGLKContext *)view.context clear:GL_COLOR_BUFFER_BIT];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition numberOfCoordinates:3 attribOffset:offsetof(SceneVertex, position) shouldEnable:YES];
    
    [self.vertexBuffer prepareToDrawWithAttrib:GLKVertexAttribNormal numberOfCoordinates:3 attribOffset:offsetof(SceneVertex,normal) shouldEnable:YES];
    
    [self.vertexBuffer drawArrayWithMode:GL_TRIANGLES startVertexIndex:0 numberOfVertices:sizeof(triangles)/sizeof(SceneVertex)];
    
    if (self.shouldDrawNormals)
    {
        [self drawNormals];
    }
}
- (void)drawNormals
{
    GLKVector3  normalLineVertices[NUM_LINE_VERTS];
    
    // calculate all 50 vertices based on 8 triangles
    SceneTrianglesNormalLinesUpdate(triangles,
                                    GLKVector3MakeWithArray(self.baseEffect.light0.position.v),
                                    normalLineVertices);
    
    [self.extraBuffer reinitWithAttribStride:sizeof(GLKVector3)
                            numberOfVertices:NUM_LINE_VERTS
                                       bytes:normalLineVertices];
    
    [self.extraBuffer prepareToDrawWithAttrib:GLKVertexAttribPosition
                          numberOfCoordinates:3
                                 attribOffset:0
                                 shouldEnable:YES];
    
    // Draw lines to represent normal vectors and light direction
    // Don't use light so that line color shows
    self.extraEffect.useConstantColor = GL_TRUE;
    self.extraEffect.constantColor =
    GLKVector4Make(0.0, 1.0, 0.0, 1.0); // Green
    
    [self.extraEffect prepareToDraw];
    
    [self.extraBuffer drawArrayWithMode:GL_LINES
                       startVertexIndex:0
                       numberOfVertices:NUM_NORMAL_LINE_VERTS];
    
    self.extraEffect.constantColor =
    GLKVector4Make(1.0, 1.0, 0.0, 1.0); // Yellow
    
    [self.extraEffect prepareToDraw];
    
    [self.extraBuffer drawArrayWithMode:GL_LINES 
                       startVertexIndex:NUM_NORMAL_LINE_VERTS 
                       numberOfVertices:(NUM_LINE_VERTS - NUM_NORMAL_LINE_VERTS)];
}

- (IBAction)takeShouldUseFaceNormalsFrom:(UISwitch *)sender;
{
    self.shouldUseFaceNormals = sender.isOn;
}
- (IBAction)takeShouldDrawNormalsFrom:(UISwitch *)sender;
{
    self.shouldDrawNormals = sender.isOn;
}
- (IBAction)takeCenterVertexHeightFrom:(UISlider *)sender;
{
    self.centerVertexHeight=sender.value;
}

/////////////////////////////////////////////////////////////////
// This method returns the value of centerVertexHeight.
- (GLfloat)centerVertexHeight
{
    return centerVertexHeight;
}
//更改顶点E的高度
-(void)setCenterVertexHeight:(GLfloat)aValue
{
    centerVertexHeight=aValue;
    
    SceneVertex newVertexE=vertexE;
    newVertexE.position.z=self.centerVertexHeight;
    
    triangles[2]=SceneTriangleMake(vertexD,vertexB, newVertexE);
    triangles[3]=SceneTriangleMake(newVertexE,vertexB, vertexF);
    triangles[4]=SceneTriangleMake(vertexD,newVertexE, vertexH);
    triangles[5]=SceneTriangleMake(newVertexE,vertexF, vertexH);
    
    [self updateNormals];
}
//重新计算受影响后的法向量
-(void)updateNormals
{
    if (self.shouldDrawNormals) {
        SceneTrianglesUpdateFaceNormals(triangles);
    }
    else
    {
        SceneTrianglesUpdateVertexNormals(triangles);
    }
    
    [self.vertexBuffer reinitWithAttribStride:sizeof(SceneVertex) numberOfVertices:sizeof(triangles)/sizeof(SceneVertex) bytes:triangles];
}

/////////////////////////////////////////////////////////////////
// This method returns the value of shouldUseFaceNormals.
- (BOOL)shouldUseFaceNormals
{
    return shouldUseFaceNormals;
}


/////////////////////////////////////////////////////////////////
// This method sets the value of shouldUseFaceNormals and updates
// vertex normals if necessary
- (void)setShouldUseFaceNormals:(BOOL)aValue
{
    if(aValue != shouldUseFaceNormals)
    {
        shouldUseFaceNormals = aValue;
        
        [self updateNormals];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Make the view's context current
    GLKView *view = (GLKView *)self.view;
    [AGLKContext setCurrentContext:view.context];
    
    // Delete buffers that aren't needed when view is unloaded
    self.vertexBuffer = nil;
    
    // Stop using the context created in -viewDidLoad
    ((GLKView *)self.view).context = nil;
    [EAGLContext setCurrentContext:nil];
}

@end

#pragma mark - Triangle manipulation

/////////////////////////////////////////////////////////////////
// This function returns a triangle composed of the specified
// vertices.
static SceneTriangle SceneTriangleMake(
                                       const SceneVertex vertexA,
                                       const SceneVertex vertexB,
                                       const SceneVertex vertexC)
{
    SceneTriangle   result;
    
    result.vertices[0] = vertexA;
    result.vertices[1] = vertexB;
    result.vertices[2] = vertexC;
    
    return result;
}


/////////////////////////////////////////////////////////////////
// This function returns the face normal vector for triangle.
static GLKVector3 SceneTriangleFaceNormal(
                                          const SceneTriangle triangle)
{
    GLKVector3 vectorA = GLKVector3Subtract(
                                            triangle.vertices[1].position,
                                            triangle.vertices[0].position);
    GLKVector3 vectorB = GLKVector3Subtract(
                                            triangle.vertices[2].position,
                                            triangle.vertices[0].position);
    
    return SceneVector3UnitNormal(
                                  vectorA,
                                  vectorB);
}


/////////////////////////////////////////////////////////////////
// Calculates the face normal vectors for 8 triangles and then
// update the normal vectors for each vertex of each triangle
// using the triangle's face normal for all three for the
// triangle's vertices
static void SceneTrianglesUpdateFaceNormals(
                                            SceneTriangle someTriangles[NUM_FACES])
{
    int                i;
    
    for (i=0; i<NUM_FACES; i++)
    {
        GLKVector3 faceNormal = SceneTriangleFaceNormal(
                                                        someTriangles[i]);
        someTriangles[i].vertices[0].normal = faceNormal;
        someTriangles[i].vertices[1].normal = faceNormal;
        someTriangles[i].vertices[2].normal = faceNormal;
    }
}


/////////////////////////////////////////////////////////////////
// This function calculates the face normal vectors for 8
// triangles and then updates the normal vector for each vertex
// by averaging the face normal vectors of each triangle that
// shares the vertex.
static void SceneTrianglesUpdateVertexNormals(
                                              SceneTriangle someTriangles[NUM_FACES])
{
    SceneVertex newVertexA = vertexA;
    SceneVertex newVertexB = vertexB;
    SceneVertex newVertexC = vertexC;
    SceneVertex newVertexD = vertexD;
    SceneVertex newVertexE = someTriangles[3].vertices[0];
    SceneVertex newVertexF = vertexF;
    SceneVertex newVertexG = vertexG;
    SceneVertex newVertexH = vertexH;
    SceneVertex newVertexI = vertexI;
    GLKVector3 faceNormals[NUM_FACES];
    
    // Calculate the face normal of each triangle
    for (int i=0; i<NUM_FACES; i++)
    {
        faceNormals[i] = SceneTriangleFaceNormal(
                                                 someTriangles[i]);
    }
    
    // Average each of the vertex normals with the face normals of
    // the 4 adjacent vertices
    newVertexA.normal = faceNormals[0];
    newVertexB.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[1]),
                                                                             faceNormals[2]),
                                                               faceNormals[3]), 0.25);
    newVertexC.normal = faceNormals[1];
    newVertexD.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[0],
                                                                                           faceNormals[2]),
                                                                             faceNormals[4]),
                                                               faceNormals[6]), 0.25);
    newVertexE.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[2],
                                                                                           faceNormals[3]),
                                                                             faceNormals[4]),
                                                               faceNormals[5]), 0.25);
    newVertexF.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[1],
                                                                                           faceNormals[3]),
                                                                             faceNormals[5]),
                                                               faceNormals[7]), 0.25);
    newVertexG.normal = faceNormals[6];
    newVertexH.normal = GLKVector3MultiplyScalar(
                                                 GLKVector3Add(
                                                               GLKVector3Add(
                                                                             GLKVector3Add(
                                                                                           faceNormals[4],
                                                                                           faceNormals[5]),
                                                                             faceNormals[6]),
                                                               faceNormals[7]), 0.25);
    newVertexI.normal = faceNormals[7];
    
    // Recreate the triangles for the scene using the new
    // vertices that have recalculated normals
    someTriangles[0] = SceneTriangleMake(
                                         newVertexA,
                                         newVertexB,
                                         newVertexD);
    someTriangles[1] = SceneTriangleMake(
                                         newVertexB,
                                         newVertexC,
                                         newVertexF);
    someTriangles[2] = SceneTriangleMake(
                                         newVertexD,
                                         newVertexB, 
                                         newVertexE);
    someTriangles[3] = SceneTriangleMake(
                                         newVertexE, 
                                         newVertexB, 
                                         newVertexF);
    someTriangles[4] = SceneTriangleMake(
                                         newVertexD, 
                                         newVertexE, 
                                         newVertexH);
    someTriangles[5] = SceneTriangleMake(
                                         newVertexE, 
                                         newVertexF, 
                                         newVertexH);
    someTriangles[6] = SceneTriangleMake(
                                         newVertexG, 
                                         newVertexD, 
                                         newVertexH);
    someTriangles[7] = SceneTriangleMake(
                                         newVertexH, 
                                         newVertexF, 
                                         newVertexI);
}


/////////////////////////////////////////////////////////////////
// This function initializes the values in someNormalLineVertices
// with vertices for lines that represent the normal vectors for 
// 8 triangles and a line that represents the light direction.
static  void SceneTrianglesNormalLinesUpdate(
                                             const SceneTriangle someTriangles[NUM_FACES],
                                             GLKVector3 lightPosition,
                                             GLKVector3 someNormalLineVertices[NUM_LINE_VERTS])
{
    int                       trianglesIndex;
    int                       lineVetexIndex = 0;
    
    // Define lines that indicate direction of each normal vector 
    for (trianglesIndex = 0; trianglesIndex < NUM_FACES;
         trianglesIndex++)
    {
        someNormalLineVertices[lineVetexIndex++] = 
        someTriangles[trianglesIndex].vertices[0].position;
        someNormalLineVertices[lineVetexIndex++] = 
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[0].position, 
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[0].normal, 
                                               0.5));
        someNormalLineVertices[lineVetexIndex++] = 
        someTriangles[trianglesIndex].vertices[1].position;
        someNormalLineVertices[lineVetexIndex++] = 
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[1].position, 
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[1].normal, 
                                               0.5));
        someNormalLineVertices[lineVetexIndex++] = 
        someTriangles[trianglesIndex].vertices[2].position;
        someNormalLineVertices[lineVetexIndex++] = 
        GLKVector3Add(
                      someTriangles[trianglesIndex].vertices[2].position, 
                      GLKVector3MultiplyScalar(
                                               someTriangles[trianglesIndex].vertices[2].normal, 
                                               0.5));
    }
    
    // Add a line to indicate light direction
    someNormalLineVertices[lineVetexIndex++] = 
    lightPosition;
    
    someNormalLineVertices[lineVetexIndex] = GLKVector3Make(
                                                            0.0, 
                                                            0.0, 
                                                            -0.5);
}

#pragma mark - Utility GLKVector3 functions

/////////////////////////////////////////////////////////////////
// Returns a unit vector in the same direction as the cross
// product of vectorA and VectorB
GLKVector3 SceneVector3UnitNormal(
                                  const GLKVector3 vectorA,
                                  const GLKVector3 vectorB)
{
    return GLKVector3Normalize(
                               GLKVector3CrossProduct(vectorA, vectorB));
}




