#ifndef FILTERS_H
#define FILTERS_H

#ifdef __cplusplus
extern "C" {
void negative(Image in);
int getRed(int pixel);
int getBlue(int pixel);
int getGreen(int pixel);
void setRed(int pixel, int value);
void setBlue(int pixel, int value);
void setGreen(int pixel, int value);
}
#endif
#endif //FILTERS_H
