cmake_minimum_required(VERSION 3.10)
project(mi_proyecto_sdl C)

set(CMAKE_C_STANDARD 11)

# Genera el archivo que Neovim (clangd) usa para el autocompletado perfecto
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Buscar SDL2 en el sistema
find_package(SDL2 REQUIRED)
include_directories(${SDL2_INCLUDE_DIRS})

# Añadir el ejecutable
add_executable(mi_programa src/main.c)

# Enlazar la librería SDL2
target_link_libraries(mi_programa PRIVATE ${SDL2_LIBRARIES})
