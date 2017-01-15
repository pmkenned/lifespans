#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <stdlib.h>

#define BUFFER_SIZE 100
#define DIB_SIZE 4

// border:          r=0x96, g=0x96, b=0x96
// land:            r=0xee, g=0xee, b=0xee
// coast:           r=0xc0, g=0xc0, b=0xc0
// water:           r=0x99, g=0xb3, b=0xcc

typedef struct {
    int r, g, b;
} PIXEL;

typedef struct {
    // bitmap file header
    short signature;
    int file_size;
    short reserved1, reserved2;
    int file_offset_to_pixelarray;

    // dib header
    int dib_header_size;
    int image_width;
    int image_height;
    short planes;
    short bits_per_pixel;
    int compression;
    int image_size;
    int x_pixels_per_meter;
    int y_pixels_per_meter;
    int colors_in_color_table;
    int important_color_count;
    int red_channel_bitmask;
    int green_channel_bitmask;
    int blue_channel_bitmask;
    int alpha_channel_bitmask;
    int color_space_type;
    int color_space_endpoints[9];
    int gamma_for_red_channel;
    int gamma_for_green_channel;
    int gamma_for_blue_channel;
    int intent;
    int icc_profile_data;
    int icc_profile_size;
    int reserved;

    int * color_table;
    PIXEL * pixel_array;
    char * icc_color_profile;
} BMP;

size_t read_file(const char * file_name, char ** data)
{
    FILE * fp;
    char buffer[BUFFER_SIZE];
    size_t n;

    size_t length = 0; // does not include null byte
    size_t cap = 100; // includes null byte
    *data = (char *) malloc(sizeof(*data)*cap);
    (*data)[0] = '\0';


    fp = fopen(file_name, "r");
    if(fp == NULL) {
        fprintf(stderr, "error: could not open file %s\n",file_name);
        exit(1);
    }

    while((n = fread(buffer, sizeof(*buffer), BUFFER_SIZE, fp)) > 0) {
        if(length + n > cap) {
            *data = realloc(*data, cap * 2);
            cap *= 2;
        }
        memcpy(*data+length, buffer, n);
        length += n;
    }

    fclose(fp);

    return length;
}

int get_int(char * data, size_t n)
{
    int x = ((data[n+3] << 24) & 0xff000000) | \
            ((data[n+2] << 16) & 0xff0000) | \
            ((data[n+1] << 8) & 0xff00) | \
             (data[n] & 0xff);
    return x;
}

int get_short(char * data, size_t n)
{
    int x = ((data[n+1] << 8) & 0xff00) | \
             (data[n] & 0xff);
    return x;
}

void parse_bmp(char * bmp_data, BMP * bmp)
{
    int i;
    int w, h, r, c, offset, padding, rs;

    bmp->file_size                   = get_int(bmp_data,2);
    bmp->file_offset_to_pixelarray   = get_int(bmp_data,10);
    bmp->dib_header_size             = get_int(bmp_data,14);
    bmp->image_width                 = get_int(bmp_data,18);
    bmp->image_height                = get_int(bmp_data,22);
    bmp->planes                      = get_short(bmp_data,26);
    bmp->bits_per_pixel              = get_short(bmp_data,28);
    bmp->compression                 = get_int(bmp_data,30);
    bmp->image_size                  = get_int(bmp_data,34);
    bmp->x_pixels_per_meter          = get_int(bmp_data,38);
    bmp->y_pixels_per_meter          = get_int(bmp_data,42);
    bmp->colors_in_color_table       = get_int(bmp_data,46);
    bmp->important_color_count       = get_int(bmp_data,50);
//    bmp->red_channel_bitmask         = get_int(bmp_data,54);
//    bmp->green_channel_bitmask       = get_int(bmp_data,58);
//    bmp->blue_channel_bitmask        = get_int(bmp_data,62);
//    bmp->alpha_channel_bitmask       = get_int(bmp_data,66);
//    bmp->color_space_type            = get_int(bmp_data,70);
////    bmp->color_space_endpoints       = get_int(bmp_data,74);
//    bmp->gamma_for_red_channel       = get_int(bmp_data,110);
//    bmp->gamma_for_green_channel     = get_int(bmp_data,114);
//    bmp->gamma_for_blue_channel      = get_int(bmp_data,118);
//    bmp->intent                      = get_int(bmp_data,122);
//    bmp->icc_profile_data            = get_int(bmp_data,126);
//    bmp->icc_profile_size            = get_int(bmp_data,130);
//    bmp->reserved                    = get_int(bmp_data,134);

    bmp->color_table = (int *) malloc(sizeof(int) * bmp->colors_in_color_table);

    for(i=0; i<bmp->colors_in_color_table; i++) {
        bmp->color_table[i] = get_int(bmp_data,102+i*4);
    }

    w = bmp->image_width;
    h = bmp->image_height;
    offset = bmp->file_offset_to_pixelarray;

    bmp->pixel_array = malloc(sizeof(*(bmp->pixel_array)) * w*h);

    padding = (w*3) % 4;
    rs = w*3+padding;

    for(r=0; r < h; r++) {
        for(c=0; c < w; c++) {
            bmp->pixel_array[r*w+c].b = (bmp_data[offset+r*rs+c*3] & 0xff);
            bmp->pixel_array[r*w+c].g = (bmp_data[offset+r*rs+c*3+1] & 0xff);
            bmp->pixel_array[r*w+c].r = (bmp_data[offset+r*rs+c*3+2] & 0xff);
        }
    }

}

void print_bmp(BMP * bmp)
{
    int i, r, c, h, w;

    printf("file_size                   %d\n", bmp->file_size                    ); 
    printf("file_offset_to_pixelarray   %d\n", bmp->file_offset_to_pixelarray    );
    printf("dib_header_size             %d\n", bmp->dib_header_size              );
    printf("image_width                 %d\n", bmp->image_width                  );
    printf("image_height                %d\n", bmp->image_height                 );
    printf("planes                      %hd\n", bmp->planes                      );
    printf("bits_per_pixel              %hd\n", bmp->bits_per_pixel              );
    printf("compression                 %d\n", bmp->compression                  );
    printf("image_size                  %d\n", bmp->image_size                   );
    printf("x_pixels_per_meter          %d\n", bmp->x_pixels_per_meter           );
    printf("y_pixels_per_meter          %d\n", bmp->y_pixels_per_meter           );
    printf("colors_in_color_table       %d\n", bmp->colors_in_color_table        );
    printf("important_color_count       %d\n", bmp->important_color_count        );
//    printf("red_channel_bitmask         %d\n", bmp->red_channel_bitmask          );
//    printf("green_channel_bitmask       %d\n", bmp->green_channel_bitmask        );
//    printf("blue_channel_bitmask        %d\n", bmp->blue_channel_bitmask         );
//    printf("alpha_channel_bitmask       %d\n", bmp->alpha_channel_bitmask        );
//    printf("color_space_type            %d\n", bmp->color_space_type             );
////    printf("color_space_endpoints       %d\n", bmp->color_space_endpoints        );
//    printf("gamma_for_red_channel       %d\n", bmp->gamma_for_red_channel        );
//    printf("gamma_for_green_channel     %d\n", bmp->gamma_for_green_channel      );
//    printf("gamma_for_blue_channel      %d\n", bmp->gamma_for_blue_channel       );
//    printf("intent                      %d\n", bmp->intent                       );
//    printf("icc_profile_data            %d\n", bmp->icc_profile_data             );
//    printf("icc_profile_size            %d\n", bmp->icc_profile_size             );
//    printf("reserved                    %d\n", bmp->reserved                     );

    printf("colors:\n");
    for(i=0; i<bmp->colors_in_color_table; i++) {
        printf("%d\n",bmp->color_table[i]);
    }

    w = bmp->image_width;
    h = bmp->image_height;

    printf("pixels:\n");
    for(r=0; r < h; r++) {
        for(c=0; c < w; c++) {
            printf("%02x ",bmp->pixel_array[r*w+c].r);
            printf("%02x ",bmp->pixel_array[r*w+c].g);
            printf("%02x ",bmp->pixel_array[r*w+c].b);
            if(c < w-1)
                printf("; ");
        }
        printf("\n");
    }

}

void find_areas(BMP * bmp) {
    PIXEL * pixels = bmp->pixel_array;
    int w = bmp->image_width;
    int h = bmp->image_height;
    int r, c;

    for(r=0; r<h; r++) {
        for(c=0; c<w; c++) {
            
        }
    }
}

int main(int argc, char * argv[])
{
    char * data;
    BMP bmp;
    int i;

    if(argc < 2) {
        fprintf(stderr, "usage: %s [FILE]\n",argv[0]);
        return 1;
    }

    size_t n = read_file(argv[1], &data);

    parse_bmp(data, &bmp);

    //printf("%d\n",bmp.image_width);
    //printf("%d\n",bmp.image_height);

    print_bmp(&bmp);

    return 0;
}
