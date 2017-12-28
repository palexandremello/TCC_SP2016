;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                      ;
;                                                                      ;
;                Universidade Federal de Pelotas                       ;
;                     Utilização livre das funções e                   ;
;                              modificações                            ;
;                                                                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;  File:       previsao_conjuntoTCC.ncl
;;
;;  Author:     Paulo Alexandre da Silva Mello
;;              Universidade Federal de Pelotas
;;  
;;  Date:       Sun 17-09-2017 
;;
;;  Description: Esse script conterá todas as funções utilizada no meu TCC
;;               Sobre utilização da previsão por conjunto.
;;               
;;
;;       load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/previsao_conjuntoTCC.ncl"
;;             
;;        Utilizando o load acima, você conseguirá utilizar todos as funções listadas
;;                                    abaixo
;;

;**************************************************************************;
; Function : chuva_medianaarea                                             ;
;                  data: numeric -> dado utilizado(membros,tempo,lat,lon)  ;
;                  lat: numeric ->  Latitudes na área a ser feita a media  ;
;                  lon: numeric ->  Longitudes na área a ser feita a media ;
;                  lat2d: numeric ->  Latitudes do data  original          ;
;                  lon2d: numeric ->  Longitudes do data original          ;
;            reftype[1]:string                                             ;
;                                                                          ;
; Será realizado a média na área respectivado aos lat e lon informados     ;
; E a matriz soma será produto de quantos membros há no data e,            ;
; total de instantes de tempo -> soma(tempo,membros)                       ; 
; função utilizada para calcular chuva média na área do ensemble           ;
;**************************************************************************;
undef("chuva_medianaarea")
function chuva_medianaarea(data:numeric,lat:numeric, lon:numeric,lat2d:numeric,lon2d:numeric )
local re, rad, con, clat, dlat, dlon, dx, dy, dxdy, wgt, soma,chuva, j,i

begin

  j=0

; SECTION ONDE É REALIZADO OS PESOS PARA A MEDIA NA ÁREA
;============================================================
  re   = 6.37122e06
  rad  = 4.0 * atan(1.0) / 180.0
  con  = re * rad                 
  clat = cos(lat * rad)      
  dlon = lon(2) - lon(1)
  dlat = lat(4) - lat(3)
;==============================================================

; INTERPOLAÇÃO DA GRADE E FINALIZANDO OS PESOS DA ÁREA
;==================================================================================================
  chuva = rcm2rgrid(lat2d,lon2d,data,lat,lon,0)
  soma = new((/ dimsizes(chuva(0,:,0,0)), dimsizes(chuva(:,0,0,0)) /),float) ; SOMA(TEMPO,MEMBROS)
  chuva!0 = "membros"
  chuva!1 = "time"
  chuva!3 = "lon"
  chuva!2 = "lat"
  chuva&lon = lon
  chuva&lat = lat
  chuva&lat@units = "degrees_north"
  chuva&lon@units = "degrees_east"

  
   dx   = con * dlon * clat        ; dx at each latitude
   dy   = con * dlat               ; dy is constant
   dxdy = dy * dx  

   wgt  = new((/dimsizes(lat), dimsizes(lon)/), typeof(chuva))

   wgt  = conform(wgt, dxdy, 0)
;=================================================================================================

;REALIZAÇÃO DA MEDIA NA ÁREA, DO IMPLICITO -> K(TEMPO) X I(MEMBROS) = TOTAL DE LOOPS 

;==================================================================================================
  do k = 0,dimsizes(chuva(:,0,0,0))-1    
      
      do i = 0,dimsizes(chuva(0,:,0,0))-1

              soma(i,k) = wgt_areaave2(chuva(k,i,:,:), wgt, 0)  
      end do
  
  end do
;===================================================================================================
 
 return(soma) ; RETORNA UMA VARIAVEL SOMA(TEMPO,MEMBROS)

end


;**************************************************************************;
; Function : prob_forecasting_limits                                       ;
;                  data: numeric -> dado utilizado(membros,tempo,lat,lon)  ;
;                  INIT_LIMITS -> limites utilizados para prev de prob(1D) ; 
;                                                                          ;
; Realiza Previsão de Probabilidade apartir de limites definidos           ;
; O dado de entrada precisa ser 4D pois o resultado final é                ;
; PROB(INDICES,TEMPO,LAT,LON)                                              ; 
;                                                                          ;
;**************************************************************************;

undef("prob_forecasting_limits")
function prob_forecasting_limits(data:numeric,init_limits:numeric)
local lat,lon,j,i,prob,ninit_limits,v,it,k

begin

  j=0

; SECTION ONDE É REALIZADO OS PESOS PARA A MEDIA NA ÁREA
;============================================================
 ninit_limits = dimsizes(init_limits)
;==============================================================

; INTERPOLAÇÃO DA GRADE E FINALIZANDO OS PESOS DA ÁREA
;==================================================================================================
 prob = new(  (/ninit_limits, dimsizes(data(0,:,0,0)) , dimsizes(data(0,0,:,0)), dimsizes(data(0,0,0,:))/),"float")
; 4D => Limites,tempo,lat,lon
;=================================================================================================

;REALIZAÇÃO DA MEDIA NA ÁREA, DO IMPLICITO -> K(MEMBROS) X I(TEMPO) = TOTAL DE LOOPS 

;==================================================================================================
  do v = 0,ninit_limits-1 ; limites
       
       do k = 0,dimsizes(data(0,:,0,0))-1 ;time
       
            do it = 0,dimsizes(data(0,0,:,0))-1 ; lat

                 do i = 0,dimsizes(data(0,0,0,:))-1   ;lon  

        
                        prob(v,k,it,i) =  ((num(data(:,k,it,i) .ge. init_limits(v))/tofloat(dimsizes(data(:,0,0,0)))))*100.   
        
                
                 end do
        
              end do
         
         end do
    
    end do

;===================================================================================================
 
 return(prob) ; RETORNA UMA VARIAVEL PROB(LIMITES,TEMPO,LAT,LON)
end

 ;**************************************************************************;
; Function : prob_forecasting_limits2                                       ;
;                  data: numeric -> dado utilizado(membros,tempo,lat,lon)  ;
;                  INIT_LIMITS -> limites utilizados para prev de prob(1D) ; 
;                                                                          ;
; Realiza Previsão de Probabilidade apartir de limites definidos           ;
; O dado de entrada precisa ser 4D pois o resultado final é                ;
; PROB(INDICES,TEMPO,LAT,LON)                                              ; 
;                                                                          ;
;**************************************************************************;

undef("prob_forecasting_2limits")
function prob_forecasting_2limits(data:numeric,init_limits:numeric,final_limits:numeric)
local lat,lon,j,i,prob,ninit_limits,nfinal_limits,v,it,k

begin

  j=0

; SECTION ONDE É REALIZADO OS PESOS PARA A MEDIA NA ÁREA
;============================================================
 ninit_limits = dimsizes(init_limits)
 nfinal_limits = dimsizes(final_limits)
;==============================================================

; INTERPOLAÇÃO DA GRADE E FINALIZANDO OS PESOS DA ÁREA
;==================================================================================================
 prob = new(  (/ninit_limits, dimsizes(data(0,:,0,0)) , dimsizes(data(0,0,:,0)), dimsizes(data(0,0,0,:))/),"float")

;=================================================================================================

;REALIZAÇÃO DA MEDIA NA ÁREA, DO IMPLICITO -> K(MEMBROS) X I(TEMPO) = TOTAL DE LOOPS 

;==================================================================================================
  do v = 0,ninit_limits-1
       
       do k = 0,dimsizes(data(0,:,0,0))-1
       
            do it = 0,dimsizes(data(0,0,:,0))-1

                 do i = 0,dimsizes(data(0,0,0,:))-1     

        
                        prob(v,k,it,i) =  ((num(data(:,k,it,i) .ge. init_limits(v) .and. \
                                                data(:,k,it,i) .lt. final_limits(v))/tofloat(dimsizes(data(:,0,0,0)))))*100.   
        
                
                 end do
        
              end do
         
         end do
    
    end do

;===================================================================================================
 
 return(prob) ; RETORNA UMA VARIAVEL PROB(LIMITES,TEMPO,LAT,LON)

end