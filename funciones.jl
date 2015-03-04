
function bin_a_10(y::ASCIIString) #esta función toma una cadena de 1's y 0's y la transforma en un entero base 10
    if y[1]=='-' #este if lo puse para incluir números negativos
        x=y[2:length(y)]
        b=-1
    else
        x=y
        b=1
    end
    a=0
    for i=0:length(x)-1
        if x[i+1]!='0' && x[i+1]!='1'
            error("Debe ser cadena de 0's y 1's")
        else
            if x[i+1]=='1'
                a=a+2^(length(x)-i-1)
            end
        end
    end
    b*a
end

function bin_a_10_con_punto(y::ASCIIString) #función que transforma cadena binaria (con "punto binario") a base 10
    if y[1]=='-' #este if es para incluir negativos
        x=y[2:length(y)]
        c=-1
    else
        x=y
        c=1
    end
    b=search(x,'.')
    if b==0 #esto es si no hay punto decimal en la cadena
        error("Debe ser cadena de 0's , 1's y un punto decimal")
    elseif search(x,'.',b+1)!=0 #esto es si hay más de un punto en la cadena
        error("Debe ser cadena de 0's , 1's y un punto decimal")
    else
    a=0.0
    for i=0:length(x)-1
            if x[i+1]!='0' && x[i+1]!='1' && x[i+1]!='.' #esto es si hay caracteres distintos a 1, 0, '.'
            error("Debe ser cadena de 0's , 1's y un punto decimal")
            elseif i+1<b[1] && x[i+1]=='1'     #si estamos antes del punto (parte entera)
                a=a+2.0^(b[1]-i-2)
            elseif i+1>b[1] && x[i+1]=='1'     #si estamos después del punto
                a=a+2.0^(b[1]-i-1)             
            end
        end          
    end
    c*a
end


function diez_a_bin(m::Int64) #esta función toma un entero base 10 y lo convierte en cadena de caracteres (base 2)
    if m==2^63
        m=0
    end
    n=abs(m)
    if n==0
        a=0
    else
        if float64(itrunc(log(big(2),big(n)))-log(big(2),big(n)))==-1.0
            long=itrunc(log(big(2),big(n)))+1 #Este es un parche para evadir las cadenas infinitas de 9's
                                                #si no me crees deja solo el long de abajo (que es el correcto analíticamente)
                                                #y compara tu función con la función bin para m=14,25,28,50
        else
            long=itrunc(log(big(2),big(n)))
        end
        a=zeros(Int,long+1)
        a[1]=1
        b=n-big(2)^long
        while b>0
            c=itrunc(log(big(2),big(b)))
            a[long-c+1]=1
            b=b-big(2)^c    
        end
    end

    
    if abs(m)==m #este if es para incluir enteros negativos
        join(a)
    else
        string('-',join(a))
    end
end	

function diez_a_bin_con_punto(x::Float64) #función que transforma flotante a cadena de caracteres
    if x==0.0
        d="0.0"
    else
        if x>2.0^53
            error("debe ser un flotante menor que 2.0^53")
        else
            n=itrunc(abs(x)) #primero trato con la parte entera
            if n==0
                d="0."
                m=53-itrunc(log2(abs(x))) #con esto la long de la cadena coincide con la longitud de la mantissa de 'bits'
            else
                d=string(diez_a_bin(n),".")
                m=52-length(d)+2 #con esto la long de la cadena coincide con la longitud de la mantissa de 'bits'
            end
               
            b=abs(x)-itrunc(abs(x))     #ahora trato con la parte no entera
            for c=1:m
                if b-2.0^(-c)<0.0
                    d=string(d,"0")
                else
                    d=string(d,"1")
                    b=b-2.0^(-c)
                end
            end
        end
    end
    if abs(x)==x #este if es para incluir negativos
        d
    else
        d=string('-',d)
    end
end

function mantissa(x::Float64) #esta función da la mantisa de diez_a_bin_con_punto (para poder comparara con la funcion bits)
    if x==0.0
        como_bits=repeat("0",52) #Mi función arroja "0.0" con x=0.0, pero quiero comparar con la función bits
    else
        c=diez_a_bin_con_punto(x)
        #println(c)
        if c[1]=='-' #solo quito el signo de la cadena
            a=c[2:length(c)]
        else
            a=c
        end
        if a[1]=='1' #si tiene parte entera, quito el primer 1 y el punto
            b=search(a,'.')
            como_bits=a[2:b-1]*a[b+1:length(a)]
        else
            b=search(a,'1') #si no tiene parte entera, solo voy hasta el primer uno y tomo lo que está a la derecha
            como_bits=a[b+1:length(a)]
        end
    end
    como_bits
end

function diez_a_bin(y::Float64) #hice una función que imita a la función bits
    if y==0.0
        join(zeros(Int,64))
    else
        if y<0 #signo
            a="1"
        else
            a="0";
        end
        x=abs(y)
        
        if itrunc(x)==0 #potencia
            b=diez_a_bin(1023+itrunc(log2(x))-1)
        else
            b=diez_a_bin(1023+itrunc(log2(x)))
        end
        if length(b)!=11
            b=join(zeros(Int,11-length(b)))*b
        end
        
        c=mantissa(x) #mantissa
        
        a*b*c
    end
end


function distancia_normales(e::Int64) #esta función pide la potencia de 2 'e' y la long de la mantissa 'p'
    #y te devuelve la distancia entre numeros normales concecutivos para esa potencia
    if 52-1-e >= 0
        a="0."*repeat("0",52-1-e)*"1" #donde e es la potencia de β
    else
        a="1"*repeat("0",e-52)*".0"
    end
    bin_a_10_con_punto(a)
end

function distancia_normales(e::Int64,p::Int64) #esta función pide la potencia de 2 'e' y la long de la mantissa 'p'
    #y te devuelve la distancia entre numeros normales concecutivos para esa potencia
    if p-1-e >= 0
        a="0."*repeat("0",p-1-e)*"1" #donde e es la potencia de β
    else
        a="1"*repeat("0",e-p)*".0"
    end
    bin_a_10_con_punto(a)
end


function bits_a_10(y::ASCIIString) #Hice una función para regresar de representación bits a flotante
    if length(y)!=64
        error("Debe ser una cadena de flotantes tipo bits (64 caracteres 1's y 0's)")
    else
        
            #primero empecemos con los normales
        e=bin_a_10(y[2:12])-1023
        if e>=0 && e<=52
            cad="1"*y[13:end]
            bin_a_10_con_punto(cad[1:e+1]*"."*cad[e+2:end])
        elseif e>52 && e<1024 #con e=1024 bin_a_10_con_punto arroja Inf, pero necesito diferenciar con NaN
            cad="1"*y[13:end]
            bin_a_10_con_punto(cad*repeat("0",e-52)*".")
        
            
            #luego los casos especiales Inf y NaN
        elseif e==1024
            if y[13]=='0'
                Inf
            else
                NaN
            end
        
            
            #Y finalmente los subnormales
        elseif e<0 && e>-1023
            cad="0."*repeat("0",-1-e)*"1"*y[13:end]
            bin_a_10_con_punto(cad)
        elseif e==-1023
            cad="0."*repeat("0",-1-e)*y[13:end]
            bin_a_10_con_punto(cad)
        end
        
    end
end

