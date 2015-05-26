###

module Modulador

using PyPlot, Images, ImageView
using FixedPointNumbers

export blazeMat, grayImage, monitor2, inicia, finaliza, thetaMat, faseMatInt, escalon #, canvas2ndScreen, monitor2canvas


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
    for i=1:nHor
        for j=1:nVer
            matInt[i,j]=int64(   mod1(  (mod1(j,periodo) -periodo) *(dosPi-1)/(periodo-1)  , dosPi    )  )
        end
    end
    matInt
end
blazeMat(dosPi::Integer, periodo::Integer)=blazeMat(800, 600, dosPi, periodo)

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

img1=ImageView.view(grayImage(ones(Int64,600,800)))
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
    if size(imagen.data)==(600,800)
        img1=ImageView.view(imagen)
        destroy(toplevel(img1[1]))
        write_to_png(img1[1],dir4)
    else
        error("Deben ser imágenes de 800x600")
    end
    sleep(1.1) # esto es para que le dé tiempo de guardar y cambiar la imagen en eog Viewer
    return nothing
end

function finaliza()
    img1=ImageView.view(grayImage(ones(Int64,600,800)))
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



### Las siguientes funciones las saqué del notebook 'Pruebas-006_(generarEstructuraHaces).ipynb' en ~/Documentos/Cosas-Ijulia

function thetaMat(th) # th son los grados por los cuales se puede rotar el holograma
    # esta función da una matriz cuyas entradas representan los ángulos (van de -π a π)
    # recuerda que la convención para matrices es invertir eje Y, por eso valores negativos quedan arriba
    x=integer(ones(600)*linspace(-399,400,800)')
    y=integer(linspace(-299,300,600)*ones(800)')
    xp=cos(th*π/180)*x-sin(th*π/180)*y # rotacion
    yp=sin(th*pi/180)*x+cos(th*pi/180)*y
    atan2(yp,xp) 
end
thetaMat()=thetaMat(0)

function faseMatInt(z::Matrix,gray2pi::Int64,gray0::Int64)
    # A esta función le das como argumento una matriz cualquiera y la convierte en una 
    # matriz con entradas Int64 con valores que van desde gray0 hasta gray2pi
    if gray0<1 || gray0>256
        error("gray0 debe estar entre 1 y 256")
    end
    if gray2pi<1 || gray2pi>256
        error("gray2pi debe estar entre 1 y 256")
    end
    if gray2pi<gray0
        error("gray2pi debe ser mayor o igual que gray0")
    end
    #notemos que Gray{Ufixed8}(256)==Gray{Ufixed8}(0) -> true
    z=(z-minimum(z))/(maximum(z-minimum(z))) # Normalizo de 0 a 1
    z=((z)*(gray2pi-gray0)) #Renormalizo min=0 max=255
    z=mod(z,256)+gray0 #Obtengo módulo, ahora min=gray0 y max=gray2pi
    return(int64(z)) # finalmente convierto a enteros 
end
faseMatInt(z::Matrix)=faseMatInt(z,256,1) # si no especificas normaliza de 1 a 256 (gama entera de grises)
faseMatInt(z::Matrix,gray2pi::Int64)=faseMatInt(z,gray2pi,1) # puedes solo especificar el tope superior

function escalon(nVer::Integer, nHor::Integer, fondo::Integer, dosPi::Integer, periodo::Integer)
    if fondo<1 || fondo>256
        error("fondo debe estar entre 1 y 256")
    end
    if dosPi<1 || dosPi>256
        error("dosPi debe estar entre 1 y 256")
    end
    if dosPi<fondo
        error("dosPi debe ser mayor o igual que fondo")
    end
    matInt=zeros(Int64,nHor,nVer)
    red=fondo+(dosPi-fondo)*int64(mod(int64(linspace(1,nVer,nVer))-1,periodo)/(periodo))
    for i=1:nHor
        matInt[i,1:nVer]=red
    end
    matInt
end
escalon(dosPi::Integer, periodo::Integer)=escalon(800,600,1,dosPi,periodo)

end
