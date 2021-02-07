cmdlines

## mov -> gif

ffmpeg-only:

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -stats -i /tmp/file.mov -vf "scale=min(iw\,600):-1" -r 20 -f gif - > file-ffmpeg-only.gif

ffmpeg+convert:

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file.mov -vf "scale=min(iw\,600):-1" -r "20" -sws_flags lanczos -f image2pipe -vcodec ppm - | convert -delay 5 -layers Optimize -loop 0 - "file-ffmpeg+convert.gif"

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file.mov -vf "scale=min(iw\,600):-1" -r "20" -f image2pipe -vcodec ppm - | convert -delay 5 -layers Optimize -loop 0 - "file-ffmpeg+convert-2.gif"

ffmpeg+gifsicle:
docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file.mov -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > "file-ffmpeg+gifscile.gif"

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file.mov -vf "scale=min(iw\,500):-1" -r 20 -f gif - | gifsicle --optimize=3 --delay=3 > "file-ffmpeg+gifscile-4.gif"

## file2.mov

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file2.mov -pix_fmt rgb24 -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > "file2-ffmpeg+gifscile.gif"

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file2.mov -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > "file2-ffmpeg+gifscile-2.gif"

half the size:
docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file2.mov -vf "scale=iw/2:ih/2" -r 20 -f gif - | gifsicle --optimize=3 --delay=3 > "file2-ffmpeg+gifscile-3.gif"

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file2.mov -vf "scale=min(iw\,500):-1" -r 20 -f gif - | gifsicle --optimize=3 --delay=3 > "file2-ffmpeg+gifscile-4.gif"


## file3.mov

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file3.mov -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > "file3-ffmpeg+gifscile-1.gif"

## file4.mov

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file4.mov -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > "file4-ffmpeg+gifscile-1.gif"

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file4.mov -vf "scale=min(iw\,500):-1" -r 10 -f gif - | gifsicle --optimize=3 --delay=3 > "file4-ffmpeg+gifscile-2.gif"

Se eu usar o scaling, o resultado final fica bem desfocado. Se não usar scaling e mostrar a imagem com metade do tamanho (redimensionar janela do preview no Finder, fica nítido)


Set Terminal windows size to 73x24 (columns, lines)
Set the font size so that the window is ~500 pixels wide
Position the keys flyovers
Use Quicktime Player to do a screen recording
Select the desired area (terminal window contents, no toolbars)
Save the results as .mov (the default)
Use ffmpeg to convert to gif (no scaling!)
Use gifsicle to optimize the gif

-r 30?
docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file7.mp4 -r 30 -f gif - | gifsicle --optimize=3 --delay=3 > "file7-r30.gif"

testar se usando o kap o arquivo fica menor
ou usar ele em vez do Quicktime (já seleciona a janela corretamente)
   mas daí não terei os fontes em .mov
   dá pra salvar como mp4

TESTAR NO WINDOWS ou outra tela nao retina
tablet marcelo
celulares


Como foi:
Set Terminal windows size to 73x24 (columns, lines)
Set the font size so that the window is ~300 pixels wide
Position the keys flyovers
Use Kap to do a screen recording
Select the desired area (terminal window contents, no toolbars)
Save the results as .mp4
Use ffmpeg to convert to gif (no scaling!)
Use gifsicle to optimize the gif

docker run -v $PWD:/tmp jrottenberg/ffmpeg:4.1-alpine -i /tmp/file.mp4 -r 30 -f gif - | gifsicle --optimize=3 --delay=3 > file.gif
