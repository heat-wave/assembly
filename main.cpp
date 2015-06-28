#include <cstdio>
#include <limits>
#include <iostream>
#include <fstream>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include "image.h"
#include "filters.h"

int fd;

void saveFile(char* name, Image image) {
    std::fstream output;
    output.open(name, std::ios::binary|std::ios::out|std::ios::trunc);
    int depth = getDepth(image);
    if (depth == 24) {
        std::cout << "24-bit bitmap processing is under construction now. Please use a 32-bit source.\n";
    }
    if (depth == 32) {
        int offset = getOffset(image);
        char * buffer = new char[offset];
        read(fd, buffer, (size_t)offset);
        output.write(buffer, offset);
        for (int i = 0; i < getHeight(image); ++i) {
            for (int j = 0; j < getWidth(image); ++j) {
                int pixel = getPixel(image, i, j);
                output.write(reinterpret_cast<const char *>(&pixel), sizeof(pixel));
            }
        }
    }
    output.flush();
    output.close();
}

int main(int argc, char** argv) {

    fd = open(argv[1], O_RDONLY);
    struct stat sb;
    if (fstat(fd, &sb) == -1)
        return 1;
    char *address;
    address = (char*)mmap(NULL, (size_t)sb.st_size, PROT_READ, MAP_PRIVATE, fd, 0);
    Image img = parseImage(address);
    std::string name(argv[1]);
    name = name.substr(0, name.length() - 4);

    char command = argc == 3 ? argv[2][0] : ' ';
    switch (command) {
        case 'n':
            negative(img);
            name.append("_neg.bmp");
            break;
        default:
            name.append("_copy.bmp");
            break;
    }

    char arr[name.length() + 1];
    strcpy(arr, name.c_str());
    saveFile(arr, img);

    return 0;

}
