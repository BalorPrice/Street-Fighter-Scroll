chdir "C:\Program Files (x86)\pyz80"
xcopy "C:\Users\Howard\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source" "C:\Program Files (x86)\pyz80\test" /E /C /Q /R /Y
pyz80.py -I test/samdos2 -D DEBUG --exportfile=test/symbol.txt --mapfile=test/auto.map test/auto.asm
move /Y "C:\Program Files (x86)\pyz80\auto.dsk" "C:\Users\Howard\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source\auto.dsk"
move /Y "C:\Program Files (x86)\pyz80\test\symbol.txt" "C:\Users\Howard\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source\symbol.txt"
move /Y "C:\Program Files (x86)\pyz80\test\auto.map" "C:\Users\Howard\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source\auto.map"
del /Q "C:\Program Files (x86)\pyz80\test\*.*"
"C:\Users\Howard\Dropbox\Wombles\Quick projects\Flappy-Bird\FB main source\auto.dsk"