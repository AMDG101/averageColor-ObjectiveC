//
//  main.m
//  averageColor
//
//  Created by Nicholas Rogers on 3/1/15.
//  Copyright (c) 2015 Nicholas Rogers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define tau 2*pi

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSImage *img = [[NSImage alloc]initWithContentsOfFile:@"tmp/img.png"];
        if (!img) {
            NSLog(@"Failed to load image.");
            return 1;
        }
        
        UInt64 width = [img size].width;
        UInt64 height = [img size].height;
        
        NSBitmapImageRep *imgRep = [[NSBitmapImageRep alloc]initWithBitmapDataPlanes:NULL
                                                                          pixelsWide:width
                                                                          pixelsHigh:height
                                                                       bitsPerSample:8
                                                                     samplesPerPixel:4
                                                                            hasAlpha:YES
                                                                            isPlanar:NO
                                                                      colorSpaceName:NSCalibratedRGBColorSpace
                                                                         bytesPerRow:width * 4
                                                                        bitsPerPixel:32];
        
        NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:imgRep];
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext:context];
        
        [img drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
        
        [context flushGraphics];
        [NSGraphicsContext restoreGraphicsState];
        
        struct Pixel { uint8_t r, g, b, a; };
        
        struct Pixel *pixels = (struct Pixel *)[imgRep bitmapData];
        UInt64 count = width * height;
        
        UInt64 red = 0;
        UInt64 green = 0;
        UInt64 blue = 0;
        
        for (UInt64 y = 0; y < height; y++) {
            for (UInt64 x = 0; x < width; x++) {
                UInt64 index = x + y * width;
                red = red + pixels[index].r;
                green = green + pixels[index].g;
                blue = blue + pixels[index].b;
                //NSLog(@"Pixel at 5, 5; R: %d, G: %d, B: %d", pixels[index].r, pixels[index].b, pixels[index].g);
            }
        }
        
        red = red / count;
        blue = blue / count;
        green = green / count;
        
        NSLog(@"R: %llu, G: %llu, B: %llu", red, green, blue);
        
        NSImage *newImg = [[NSImage alloc]initWithSize:NSMakeSize(200, 200)];
        [newImg lockFocus];
        NSColor *newCol = [NSColor colorWithRed:red/255.00
                                          green:green/255.00
                                           blue:blue/255.00
                                          alpha:1.0];
        [newCol set];
        NSRectFill(NSMakeRect(0, 0, 200, 200));
        NSBitmapImageRep *newImgRep = [[NSBitmapImageRep alloc]initWithFocusedViewRect:NSMakeRect(0, 0, newImg.size.width, newImg.size.height)];
        [newImg unlockFocus];
        
        NSData *data = [newImgRep representationUsingType:NSPNGFileType properties:nil];
        [data writeToFile:@"tmp/newImg.png"
               atomically:YES];
        
    }
    return 0;
}
