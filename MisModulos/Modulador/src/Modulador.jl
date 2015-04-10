###

module Modulador

using PyPlot, Images, ImageView
using FixedPointNumbers

export blazeMat, grayImage, preparaMonitor, canvas2ndScreen, monitor2

#El siguiente run es para preparar el 2do monitor (colocación, resolución y orientación)
#El contenido del archivo PrepMonit1 lo saqué del notebook 'Pruebas-003_(Imagenes)' en ~/Documentos/Cosas-Ijulia 
run(`bash /home/santiago/Documentos/Escuela-maestría/1er-semestre/Física-computacional/Clase/MisModulos/Modulador/src/PrepMonit1`)


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

# Esta constante es el canvas (imagen) del segundo monitor, por lo que los run son para abrirlo en el 2do monitor
run(`bash /home/santiago/Documentos/Escuela-maestría/1er-semestre/Física-computacional/Clase/MisModulos/Modulador/src/PrepMonit2`)
sleep(1)
const canvas2ndScreen=ImageView.view(grayImage(ones(Int64,800,600)))

run(`bash /home/santiago/Documentos/Escuela-maestría/1er-semestre/Física-computacional/Clase/MisModulos/Modulador/src/PrepMonit3`)


function monitor2(imagen::Image)
    ImageView.view(canvas2ndScreen[1],imagen)
end



end
