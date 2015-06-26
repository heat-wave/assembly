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
}
#endif
#endif //ASSEMBLY_IMAGE_H