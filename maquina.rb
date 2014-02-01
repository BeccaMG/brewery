#!/usr/bin/env ruby

#*****************************************************************************
#--------------------- IMPLEMENTACION DE LA CLASE INSUMO ---------------------
#*****************************************************************************
class Insumo
    
    # ---------- Variables de Instancia de la Clase Insumo ---------------- #
    attr_accessor :nombre, :cantidad
    
    # ---------- Constructor de la Clase Insumo ------------- #
    #   El constructor estara implementado en las subclases   #
    def initialize
    end

    # ---------- Funcion para imprimir un Insumo ------------ #
    def imprimir
        puts "#{@nombre} #{@cantidad}"
    end
end

# ---------------- SUBCLASE INSUMOBASICO (PADRE INSUMO) ------------------ #
class InsumoBasico < Insumo
    
    # ---- Constructor para la Subclase InsumoBasico ---- #
    def initialize(nombre,cantidad)
        @nombre = nombre
        @cantidad = cantidad
    end 
end

# ------------------- SUBCLASE PRODUCTO (PADRE INSUMO) ------------------- #
class Producto < Insumo

    # ---- Constructor para la Subclase Producto ---- #
    def initialize(cantidad)
        @nombre = 'Producto Anterior'
        @cantidad = cantidad
    end
end


#*******************************************************************************
#----------------- IMPLEMENTACION DE LA CLASE MAQUINA --------------------------
#*******************************************************************************
class Maquina

    #---------- Variables de instancia de la clase Maquina ------------
    attr_accessor :nombre, :desecho, :productoAnterior, :cantidadMax, :porcentajePA,
                  :ciclosProcesamiento,:estado, :maquinaAnterior
    
    #----------- Constructor de la clase Maquina ------------
    #-- @param nombre  {string correspondiente al nombre de la maquina}
    #-- @param desecho {numero correspondiente al desecho que produce la maquina}
    #-- @param productoAnterior {instancia de Insumo correspondiente al contenedor
    #-- del Insumo PA de la maquina. A su vez, indica el contenedor en el que
    #-- la maquina anterior deposita el producto manufacturado
    #--
    #-- estado de la maquina, una
    #--        maquina recien cerada es inactiva por defecto}
    #-- @param cantidadMax {numero correspondiente a la cantidad maxima de 
    #--        insumos soportado por la maquina}
    #-- @param porcentajePA {numero correspondiente al porcentaje
    #--        de insumo soportado por de la maquina}
    #-- @param ciclosProcesamiento {numero correspondiente a los ciclos de
    #--        procesamiento requeridos por la maquina}
    #-- @param maquinaAnterior {Maquina.class un apuntador a la maquina previa}
    #-- @param productoProcesado {Instancia de Producto PA correspondiente al
    #--        contenedor de insumos de la siguiente maquina del proceso. Si es
    #--        nil se trata de la ultima maquina}
    def initialize(nombre,desecho,cantidadMax,porcentajePA,ciclosProcesamiento,
                    maquinaSiguiente,productoAnterior,productoProcesado)
                   
        #--- Variables de instancia obligatorias al invocar el constructor
        @nombre   = nombre
        @desecho  = desecho

        @cantidadMax         =  cantidadMax
        @porcentajePA        =  porcentajePA
        @ciclosProcesamiento =  ciclosProcesamiento
        
        @maquinaSiguiente    =  maquinaSiguiente
        @productoAnterior    =  productoAnterior
        @productoProcesado   =  productoProcesado
        
        #--- Variables de instancia opcionales al invocar el constructor
        @estado              =  "Inactiva"
        @cicloActual         =  ciclosProcesamiento
        @productoHecho            =  0.0
        @productoAnteriorRestante =  0.0
    end

    #---------- Metodo que ejecuta un ciclo de procesamiento ----------
    def procesamiento
    
        case @estado       
            when "Inactiva"
                cicloInactiva
            when "Procesando"
                cicloProcesamiento
            when "Espera"
                cicloEspera
            when "Llena"
                cicloLlena
            when "Llenando"
                cicloLlenando
        end
        imprimir
    end  
 
    #------ Metodo que procesa un ciclo en estado "llenando". -----
    def cicloLlenando
        
    end
     
    #------ Metodo que procesa un ciclo en estado "inactiva". -----
    def cicloInactiva
        #Lo que hay que hacer es chupar del tanque compartido, y si no alcanza
        #guardarlo en la variable de productoAnteriorRestante, la funcion cicloEspera debe
        #chequear que el tanque sea 0 para pasar a inactiva, me refiero al
        #cicloEspera de la maquina anterior. si no se entiende escribir al guasap.
        productoAnteriorRequerido = @porcentajePA * @cantidadMax
        cantidadAObtener = productoAnteriorRequerido - @productoAnteriorRestante 

        if @productoAnterior.cantidad >= cantidadAObtener
            @productoAnterior.cantidad -= cantidadAObtener
            @productoAnteriorRestante = 0.0
            @estado = "Llena"
        else
            @productoAnteriorRestante = @productoAnterior.cantidad
            @productoAnterior.cantidad = 0
        end
        
        
            
    end
    
    #------ Metodo que procesa un ciclo en estado "procesando". -----
    def cicloProcesamiento
        #-- Caso en el que aun no acaba de procesarse el producto ---
        if @cicloActual > 0
        # Se decrementa el numero de ciclos
            @cicloActual = @cicloActual - 1
        
        #-- Caso en el que los ciclos de procesamiento fueron cumplidos    
        else
            # El numero de ciclo era 0, por lo que se reinicia, se obtiene la
            # cantidad de producto manufacturado y se en una variable antes de
            # ser transferido a la siguiente maquina.
            @cicloActual = @ciclosProcesamiento
            @productoHecho = @cantidadMax * (1 - @desecho)            
            @estado = "Espera"            
        end        
    end    
    
    #------ Metodo que procesa un ciclo en estado "espera". -----
    def cicloEspera
        #MENSAJE INCOMPLETO (MENSAJE SIGNIFICA FUNCION)
        if @productoProcesado.cantidad == 0
            # Solamente debe transferir si la maquina siguiente esta lista para
            # recibir, esto es, si la maquina siguiente esta inactiva y yo
            # tengo producto para transferir.
            @productoProcesado.cantidad = @productoHecho
            @productoHecho = 0
        end
    end    
    
    #------ Metodo que procesa un ciclo en estado "llena". -----
    def cicloLlena
       #Es un ciclo de transicion, si la maquina estaba en estado "llena" debe
       #comenzar a procesar en el siguiente ciclo.
       @estado = "Procesando"
       cicloProcesamiento
    end    
    
       
    #------ Representacion en String de la clase Maquina. -----
    #-- Imprime en pantalla dicha representacion
    def imprimir
        maquina = "Maquina " + @nombre + "\n" + "Estado: " + @estado +"\n"
        
        puts maquina
        #-- Solo se imprimen los insumos asociados a la maquina en caso de 
        #-- que esta se encuentre en estado inactiva o llena
        case @estado
            when "Llena","Inactiva"
                puts "Insumos:\n"
                @productoAnterior.imprimir
        end
    end
#--Fin de la clase Maquina
end






numCiclos = ARGV[0]
cebada    = ARGV[1]
arrozMaiz = ARGV[2]
levadura  = ARGV[3]
lupulo    = ARGV[4]


#FALTA PONER LAS MAQUINAS SIGUIENTES

#silosCebada    = MaquinaCompleja.new
tanque1 = Producto.new(0)
#pailaMezcla    = MaquinaCompleja.new
tanque2 = Producto.new(0)
#pailaCoccion   = MaquinaCompleja.new
tanque3 = Producto.new(0)
tanque4 = Producto.new(0)
#tcc            = MaquinaCompleja.new
tanque5 = Producto.new(0)
tanque6 = Producto.new(0)
productoFinal = Producto.new(0)


llenaTapa      = Maquina.new("Llenadora y Tapadora", 0.0, 50, 100, 2, nil, tanque6, productoFinal)
tanqueFiltrada = Maquina.new("Tanque para Cerveza Filtrada", 0.0, 100, 100, 0, llenaTapa, tanque5, tanque6)
filtroCerveza  = Maquina.new("Filtro de Cerveza", 0.0, 100, 100, 1, tanqueFiltrada, tanque4, tanque5)
enfriador      = Maquina.new("Enfriador", 0.0, 60, 100, 2, filtroCerveza, tanque3, tanque4)
tanque         = Maquina.new("Tanque Pre-Clarificador", 0.01, 35, 100, 1, enfriador, tanque2, tanque3)
cubaFiltracion = Maquina.new("Cuba de Filtracion", 0.35, 135, 100, 2, tanque, tanque1, tanque2)
molino         = Maquina.new("Molino", 0.02, 100, 100, 1, cubaFiltracion, nil, tanque1)

cubaFiltracion.procesamiento


