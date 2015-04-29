###

module Modulador

using PyPlot, Images, ImageView
using FixedPointNumbers

export blazeMat, grayImage, monitor2, inicia, finaliza#, canvas2ndScreen, monitor2canvas


#El contenido del archivo PrepMonit1 lo saqué del notebook 'Pruebas-003_(Imagenes)' en ~/Documentos/Cosas-Ijulia 
#run(`bash /home/atomosfrios/Documents/Cosas_Julia/LabAtomosFrios/Modulador/src/PrepMonit1`)
dir=joinpath(LOAD_PATH[length(LOAD_PATH)],"Modulador","src")
dir1=joinpath(dir,"PrepMonit1")
dir2=joinpath(dir,"PrepMonit2")
dir2canvas=joinpath(dir,"PrepMonit2canvas")
dir3=joinpath(dir,"PrepMonit3")
dir4=joinpath(dir,"imagen")


#Las siguientes funciones las saqué del notebook 'Pruebas-004_(generarImagenesGrises)' en ~/Documentos/Cosas-Ijulia 

#La función blazeMat da un arreglo de nVer × nHor enteros que representa una rejilla blaze. El tercer argumento que toma la función es el entero que representa la fase 2π y el cuarto argumento es el periodo (en pixeles).
#La función grayImage toma como argumento una matriz de enteros de nVer × nHor(como la que genera blazeMat) y la convierte en una imagen.
function blazeMat(nVer::Integer, nHor::Integer, dosPi::Integer, periodo::Integer)
    matInt=zeros(Int64,nHor,nVer)
    for i=1:nVer
        for j=1:nHor
            matInt[j,i]=int64(   mod1(  (mod1(j,periodo) -periodo) *(dosPi-1)/(periodo-1)  , dosPi    )  )
        end
    end
    matInt
end
blazeMat(dosPi::Integer, periodo::Integer)=blazeMat(600, 800, dosPi, periodo)

function grayImage(matInt::Array{Int64,2})
    nVer=size(matInt)[1]
    nHor=size(matInt)[2]
    matGray=zeros(Gray{Ufixed8},nVer,nHor)
    for i=1:nVer
        for j=1:nHor
            matGray[i,j]=Gray{Ufixed8}(matInt[i,j])
        end
    end
    Image(matGray)
end

img1=ImageView.view(grayImage(ones(Int64,800,600)))
destroy(toplevel(img1[1]))
write_to_png(img1[1],dir4)


println("Bienvenido al módulo que controla el SLM.
    Para empezar utiliza la función inicia.
    ¡¡Recuerda correr la función finaliza al terminar tu sesión!!")


function inicia()
    #El siguiente run es para preparar el 2do monitor (colocación, resolución y orientación)    
    run(`bash $(Modulador.dir1)`)
    sleep(3)
    #El siguiente run es para abrir EOG en 2do monitor Fullscreen  
    run(`bash $(Modulador.dir2)`)
    sleep(2)
    ##### Esto es para versión con Eye of Gnome 
    spawn(`eog --fullscreen $dir4 &`)
    ##### Esto es para versión con Eye of Gnome 
end


function monitor2(imagen::Image)
    ##### Esto es para versión con Eye of Gnome
    if size(imagen.data)==(800,600)
        img1=ImageView.view(imagen)
        destroy(toplevel(img1[1]))
        write_to_png(img1[1],dir4)
    else
        error("Deben ser imágenes de 800x600")
    end
end

function finaliza()
    img1=ImageView.view(grayImage(ones(Int64,800,600)))
    destroy(toplevel(img1[1]))
    write_to_png(img1[1],dir4)
    run(`bash $(Modulador.dir3)`)
end


##### Esto es para versión con Canvas (no fullscreen)
##### Esto es para versión con Canvas (no fullscreen) 
#run(`bash $dir2canvas`)
#const canvas2ndScreen=ImageView.view(grayImage(ones(Int64,800,600)))   
    # Esta constante es el canvas (imagen) del segundo monitor, por lo que los run son para abrirlo en el 2do monitor

#function monitor2canvas(imagen::Image)    
#    ImageView.view(canvas2ndScreen[1],imagen)
#end
##### Esto es para versión con Canvas (no fullscreen) 
##### Esto es para versión con Canvas (no fullscreen)


end
