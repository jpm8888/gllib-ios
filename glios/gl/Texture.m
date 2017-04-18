//
//  Texture.m
//  GLKViewExample
//
//  Created by Psi Gem on 01/04/17.
//  Copyright © 2017 Nexogen. All rights reserved.
//

#import "Texture.h"
#import "GLMath.h"

@implementation Texture{
    GLuint textureHandle;
}
const int NO_TEXTURE = 0;

@synthesize width, height;

-(instancetype) init :(UIImage*) image{
    if (!self) self = [super init];
    [self assignDimensions :image];
    textureHandle = [self setupTexture :image];
    return self;
}

-(instancetype) initUsingFilePath : (NSString*) imgFilePath{
    if (!self) self = [super init];
    UIImage* img = [UIImage imageNamed:imgFilePath];
    if (!img) {
        NSLog(@"Failed to load image %@", imgFilePath);
    }
    return [self init:img];
}

-(instancetype) init : (GLuint) texName : (int) w : (int) h{
    if (!self) self = [super init];
    self.width = w;
    self.height = h;
    textureHandle = texName;
    return self;
}

-(instancetype) initEmptyImage : (int) w : (int) h : (Format) f{
    if (!self) self = [super init];
    textureHandle = [self createTexture:w :h :f];
    return self;
}

-(GLuint) createTexture : (int) w : (int) h : (Format) f{
    self.width = w;
    self.height = h;
    GLubyte* imageData = (GLubyte *) calloc(w * h * 4, sizeof(GLubyte));
    GLuint texName;
    glGenTextures(1, &texName);
    
    [GLUtil checkGlError:"Texture.createTexture().glGenTextures"];
    [self setFilter:Linear :Linear] ;
    [self setWrap:ClampToEdge :ClampToEdge];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.width, self.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    [GLUtil checkGlError:"Texture.createTexture().glTexImage2D"];
    free(imageData);
    return texName;
}


-(GLuint) setupTexture :(UIImage*) image{
    GLubyte* imageData = (GLubyte *) calloc(image.size.width * image.size.height * 4, sizeof(GLubyte));
    CGContextRef imageContext = CGBitmapContextCreate(imageData, image.size.width, image.size.height, 8, image.size.width * 4, CGColorSpaceCreateDeviceRGB(),kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(imageContext, CGRectMake(0.0, 0.0, image.size.width, image.size.height), image.CGImage);
    CGContextRelease(imageContext);
    
    GLuint texName;
    glGenTextures(1, &texName);
    [GLUtil checkGlError:"glGenTextures()"];
    [self bind];
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, self.width, self.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    [GLUtil checkGlError:"glTexImage2D()"];
    [self setFilter:Linear :Linear];
    [self setWrap:ClampToEdge :ClampToEdge];
    
    free(imageData);
    image = nil;
    return texName;
}

-(void) checkTextureError :(GLuint) tex{
    if (tex == NO_TEXTURE || tex == 0){
        [GLUtil LOG:@"Texture" :@"Error in loading Texture"];
    }
}


-(void) setFilter :(TextureFilter) minFilter :(TextureFilter) magFilter {
    self.minFilter = minFilter;
    self.magFilter = magFilter;
    [self bind];
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, [self getMinFilter]);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, [self getMagFilter]);
}

-(void) setWrap :(TextureWrap) u :(TextureWrap) v {
    self.uWrap = u;
    self.vWrap = v;
    [self bind];
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, [self getuWrap]);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, [self getvWrap]);
}


-(TextureFilter) getMinFilter {
    return self.minFilter;
}

-(TextureFilter) getMagFilter {
    return self.magFilter;
}

-(TextureWrap) getuWrap {
    return self.uWrap;
}

-(TextureWrap) getvWrap {
    return self.vWrap;
}

     
-(void) assignDimensions :(UIImage*) image {
    self.width = (int) image.size.width;
    self.height = (int) image.size.height;
    [self checkPowerofTwo];
}

-(void) bind{
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    [GLUtil checkGlError:"glBindTexture()"];
}

-(void) bind : (int) unit{
    glActiveTexture(GL_TEXTURE0 + unit);
    [GLUtil checkGlError:"glActiveTexture()"];
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    [GLUtil checkGlError:"glBindTexture()"];
}

-(BOOL) checkPowerofTwo {
    BOOL wFlag = [GLMath isPowerOfTwo: self.width];
    BOOL hFlag = [GLMath isPowerOfTwo: self.height];
    if (wFlag && hFlag)
        return true;
    else
        [GLUtil LOG:@"Texture" : @"Texture is not int he power of 2^n"];
    return false;
}

-(void) updateTexture :(UIImage*) image{
    [self dispose];
    [self setupTexture:image];
}

-(void) dispose {
    glDeleteTextures(1, &textureHandle);
}

-(GLuint) getTextureHandle{
    return textureHandle;
}
     
     
@end
