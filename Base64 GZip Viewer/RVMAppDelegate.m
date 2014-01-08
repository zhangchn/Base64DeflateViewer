//
//  RVMAppDelegate.m
//  Base64 GZip Viewer
//
//  Created by zhang chen on 1/6/14.
//  Copyright (c) 2014 Raiing Medical Company. All rights reserved.
//

#import "RVMAppDelegate.h"
#import "ASIDataCompressor.h"
#import "ASIDataDecompressor.h"


NSString *Base64StringWithData(NSData *theData) {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];

    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;

    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;

            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

NSData *DataWithBase64String(NSString *theString)
{
    static unsigned char base64DecodeLookup[256] =
    {
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 62,  255, 255, 255, 63,
        52,  53,  54,  55,  56,  57,  58,  59,  60,  61,  255, 255, 255, 255, 255, 255,
        255,  0,  1,   2,   3,   4,   5,   6,   7,   8,   9,   10,  11,  12,  13,  14,
        15,  16,  17,  18,  19,  20,  21,  22,  23,  24,  25,  255, 255, 255, 255, 255,
        255, 26,  27,  28,  29,  30,  31,  32,  33,  34,  35,  36,  37,  38,  39,  40,
        41,  42,  43,  44,  45,  46,  47,  48,  49,  50,  51,  255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255,
        255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255
    };
    size_t inputSize = [theString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    size_t outputBufferSize = ((inputSize + 4 - 1) / 4) * 4;
    const uint8_t *input = (const uint8_t *)[theString UTF8String];
    unsigned char *outputBuffer = (unsigned char *)malloc(outputBufferSize);
    size_t i = 0;
    size_t j = 0;
    while (i < inputSize) {
        unsigned char accumulated[4];
        size_t accumulateIndex = 0;
        while (i < inputSize) {
            unsigned char decode = base64DecodeLookup[input[i++]];
            if (decode != 255) {
                accumulated[accumulateIndex] = decode;
                accumulateIndex++;

                if (accumulateIndex == 4)
                {
                    break;
                }
            }
        }
        if(accumulateIndex >= 2)
            outputBuffer[j] = (accumulated[0] << 2) | (accumulated[1] >> 4);
        if(accumulateIndex >= 3)
            outputBuffer[j + 1] = (accumulated[1] << 4) | (accumulated[2] >> 2);
        if(accumulateIndex >= 4)
            outputBuffer[j + 2] = (accumulated[2] << 6) | accumulated[3];
        j += accumulateIndex - 1;
    }

    NSData *result = [NSData dataWithBytes:outputBuffer length:j];
    free(outputBuffer);
    return result;
}

@implementation RVMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    [self.base64View.textStorage setAttributes:@{NSParagraphStyleAttributeName : paragraphStyle}
                                         range:NSMakeRange(0, self.base64View.string.length)];
}

- (IBAction)decode:(id)sender {
    NSString *encodedString = self.base64View.string;
    NSData *decodedUncompressedData = [ASIDataDecompressor uncompressData:DataWithBase64String(encodedString) error:nil];
    self.plainView.string = [[NSString alloc] initWithBytes:decodedUncompressedData.bytes length:decodedUncompressedData.length encoding:NSUTF8StringEncoding];
}

- (IBAction)encode:(id)sender {
    NSString *dataString = self.plainView.string;
    NSString *encodedCompressedData = Base64StringWithData([ASIDataCompressor compressData:[dataString dataUsingEncoding:NSASCIIStringEncoding] error:nil]);
    self.base64View.string = encodedCompressedData;
}
@end
