//
// Created by heat_wave on 6/25/15.
//
typedef void * Image;
//#include <fstream>

#ifndef ASSEMBLY_IMAGE_H
#define ASSEMBLY_IMAGE_H

#ifdef __cplusplus
extern "C" {
    Image parseImage(char* file);
    int getOffset(Image image);
    int getWidth(Image image);
    int getHeight(Image image);
    int getDepth(Image image);
    int getPixel(Image image, int x, int y);
    void setPixel(Image image, int x, int y, int val);
    void upgradeDepth(Image image);
    int getSize(Image image);
    Image getCopy(Image image);
}
#endif
#endif //ASSEMBLY_IMAGE_H