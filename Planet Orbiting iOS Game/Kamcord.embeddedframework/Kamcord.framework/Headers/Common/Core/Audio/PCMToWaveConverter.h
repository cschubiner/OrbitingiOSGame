#import <Foundation/Foundation.h>

typedef struct
{
    int channels;
    unsigned int freq;
    unsigned int bitDepth;
    unsigned int sampleCount;
    unsigned int loopbackSample;
} PCMSoundFileHeader;

BOOL ConvertRawPCMToWAV(NSString * inputFilePath, NSURL * outputFileURL);

