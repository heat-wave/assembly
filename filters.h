#ifndef FILTERS_H
#define FILTERS_H

#ifdef __cplusplus
extern "C" {
Image negative(Image in);
int getRed(int pixel);
int getBlue(int pixel);
int getGreen(int pixel);
}
#endif
#endif //FILTERS_H