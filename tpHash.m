#import "TpHash.h"

@implementation TpHash

+(uint64_t)ptHash:(UIImage*)image {

    image = [self scaleImage:image toSize:CGSizeMake(8,8)];
    uint8_t* imgArray = [self convertToGreyscale64Array:image];
    int sum = 0;
    for (int i = 0; i < 64; i++) {
        
        sum += imgArray[i];
    }
    uint8_t avg = sum/64;
    uint64_t ret = 0;
    for (int i = 0; i < 64; i++) {
        
        if(imgArray[i]>=avg) {
            
            ret++;
        }
        ret <<= 1;
    }
    return ret;
}

+(int)hamdist:(uint64_t)x with:(uint64_t) y
{
    unsigned dist = 0, val = x ^ y;
    
    while(val)
    {
        ++dist; 
        val &= val - 1;
    }
    
    return dist;
}

+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)newSize {

    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();    
    UIGraphicsEndImageContext();
    return newImage;
}


+(uint8_t *) convertToGreyscale64Array:(UIImage *)i {
    
    int kRed = 1;
    int kGreen = 2;
    int kBlue = 4;
    
    int colors = kGreen;
    int m_width = i.size.width;
    int m_height = i.size.height;
    
    uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGContextSetShouldAntialias(context, NO);
    CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [i CGImage]);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
    for(int y = 0; y < m_height; y++) {
        for(int x = 0; x < m_width; x++) {
            uint32_t rgbPixel=rgbImage[y*m_width+x];
            uint32_t sum=0,count=0;
            if (colors & kRed) {sum += (rgbPixel>>24)&255; count++;}
            if (colors & kGreen) {sum += (rgbPixel>>16)&255; count++;}
            if (colors & kBlue) {sum += (rgbPixel>>8)&255; count++;}
            m_imageData[y*m_width+x]=sum/count/4;
        }
    }
    free(rgbImage);
    return m_imageData;
}


@end
