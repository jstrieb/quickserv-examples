@echo off

:: Create a video of a pre-determined length with ffmpeg

ffmpeg ^
-y ^
-filter_complex "mandelbrot=size=640x360[v]" ^
-map "[v]" ^
-pix_fmt yuv420p ^
-movflags frag_keyframe+empty_moov ^
-f mp4 ^
-t 20 ^
-









