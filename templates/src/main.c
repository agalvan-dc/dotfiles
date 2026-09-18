/* main.c - minimal SDL2 entry point template (C11) */
#include <SDL2/SDL.h>

int main(void)
{
    if (SDL_Init(SDL_INIT_VIDEO) < 0)
        return 1;
    SDL_Quit();
    return 0;
}