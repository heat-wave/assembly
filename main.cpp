#include <cstdio>
#include <limits>
#include <iostream>
#include <fstream>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "image.h"
#include "filters.h"

int fd;

void saveFile(char* name, Image image) {
    std::fstream output;
    output.open(name, std::ios::binary|std::ios::out|std::ios::trunc);
    int depth = getDepth(image);
    if (depth == 24) {
        upgradeDepth(image);
        char *buffer = new char[50];
        read(fd, buffer, 2);
        output.write(buffer, 2);
        read(fd, buffer, 4);
        int sz = getSize(image);
        output.write(reinterpret_cast<const char *>(&sz), sizeof(sz));
        read(fd, buffer, 48);
        output.write(buffer, 48);
    }
    if (depth == 32) {
        int offset = getOffset(image);
        char * buffer = new char[offset];
        read(fd, buffer, (size_t)offset);
        output.write(buffer, offset);
        //Image image = negative(image);
        for (int i = 0; i < getHeight(image); ++i) {
            for (int j = 0; j < getWidth(image); ++j) {
                //setPixel(image, i, j, 0);
                int pixel = getPixel(image, i, j);
                output.write(reinterpret_cast<const char *>(&pixel), sizeof(pixel));
            }
        }
    }
    else {
        for (int i = 0; i < getHeight(image); ++i) {
            for (int j = 0; j < getWidth(image); ++j) {
                int pixel = (getPixel(image, i, j));
                output.write(reinterpret_cast<const char *>(&pixel), sizeof(pixel) - 1);
            }
        }
    }
    output.flush();
    output.close();
}

Image neg(Image im)
{
    int n = getWidth(im);
    int m = getHeignt(im);
}

int main() {

    fd = open("example3.bmp", O_RDONLY);
    struct stat sb;
    if (fstat(fd, &sb) == -1)
        return 1;
    char *address;
    address = (char*)mmap(NULL, (size_t)sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    Image img = parseImage(address);
    img = negative(img);
    if (img != NULL) {
        std::cout << "Not null!\n";
    }
    else {
        std::cout << "Null image!\n";
    }
    saveFile((char*)"example2.bmp", img);
    return 0;

}
