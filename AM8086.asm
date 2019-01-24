dane            segment
max				db		6	;max dlugosc liczby
len				db		?	;dlugosc liczby
num				db		6 dup(0)	;miejsce na liczbe
e1				db		0ah,0dh,'Podaj liczbe',0ah,0dh,'> $'
n				db 		0ah,0dh,'$' ;nowa linia
znakihex		db		'0123456789ABCDEF$'
znakibin		db		'01$' ;;
hex				db		'0000$' ;65535 = 4*4b
bin				db		'0000000000000000$' ;65535 = 16b
wypiszdec		db		0ah,0dh,'Dziesietna: $'
wypiszhex		db		0ah,0dh,'Szesnastkowa: $'
wypiszbin		db		0ah,0dh,'Binarna: $'
bladd 			db 		0ah,0dh,'Liczba nie miesci sie w zakresie lub to nie liczba',0ah,0dh,'$'

dane            ends
;______________________________________________
stoss          segment
                dw    	100h dup(0)
top          	Label word
stoss          ends
;______________________________________________
prog           segment
                assume  cs:prog, ds:dane, ss:stoss
;______________________________________________				
start:          mov     ax,dane
                mov     ds,ax
                mov     ax,stoss
                mov     ss,ax
                mov     sp,offset top
;______________________________________________		
				;wyświetlenie etykiety
				mov 	ah,09h
				mov 	dx,offset e1
				int 	21h
;______________________________________________			
				;wpisanie liczby do 6 znaków
				mov 	ah,0ah
				mov 	dx,offset max
				int 	21h
;______________________________________________		
				xor		si,si
				mov		ch,0   ;cs <- dlugosc
				mov		cl,len ; -,,-
czyliczba:		mov		bx,offset num				
				mov 	al,[bx]+si ;pobieranie znaku z wpisanego lancucha
				inc		si
				sub		al,48 ; 48 - kod znaku '0'
				cmp		al,10
				jc  	s1
				jmp		blad
s1:				loop 	czyliczba
				clc 	;przeniesienie = 0
				
				xor		si,si
				mov		ch,0   ;cx <- dlugosc
				mov		cl,len 
				xor		ax,ax ;sum= 0
czydlugosc:		mov		bx,offset num
				mov		dx,10
				mul		dx ;*10
				jnc  	s2
				jmp		blad
s2:	
				push	ax
				mov		ah,0
				mov		al,[bx]+si ;pobieranie znaku
				inc		si
				sub		al,48 ;0'
				pop		bx
				add		ax,bx ;suma
				jnc  	s3
				jmp		blad
s3:				loop	czydlugosc
				push 	ax
;______________________________________________			
				mov		ah,09h
				mov		dx,offset wypiszdec
				int 	21h
				
				;wpisanie '$' na koniec 
				mov		bh,0            ;bx <- dlugosc
				mov		bl,len           
				mov 	num[bx],'$'    ;znak '$' na koniec
			
				;wypisanie dec
				mov		ah,09h
				mov 	dx,offset num
				int		21h	
;______________________________________________			
				;konwersja na hex
				pop		ax
				xor		si,si
				xor		ch,ch
				mov		cl,4	;bo 4*4b			
				mov		dx,ax
				push	dx
konwhex:		mov		bx,000fh				
				rol		ax,4 ;o 4 bity w lewo bo hex 4*4
				and		bx,ax ;maskowanie wartości
				mov		dl,znakihex[bx] ;wyznaczanie znaku z tabeli hex 0-F
				mov		hex[si],dl ;wpisywanie znaku do wyniku
				inc		si
				loop 	konwhex
				
				;wypisanie hex		
				mov		ah,09h
				mov		dx,offset wypiszhex
				int 	21h
				
				mov		ah,09h
				mov 	dx,offset hex
				int		21h
;______________________________________________			
				;konwersja na bin
				pop		ax
				xor		si,si
				mov		ch,0
				mov		cl,16 ;16b
konwbin:		mov		bx,0000000000000001b ;;
				rol		ax,1
				and		bx,ax ;;
				mov		dl,znakibin[bx] ;;
				mov		bin[si],dl ;;
				inc		si ;
				loop	konwbin		
			
				;wypisanie bin						
				mov		ah,09h
				mov		dx,offset wypiszbin
				int 	21h
				
				mov		ah,09h
				mov 	dx,offset bin
				int		21h				
				jmp 	koniec		
;______________________________________________		
				;blad
blad:			mov		ah,09h
				mov		dx,offset bladd
				int		21h	
				
koniec:			mov ah,4ch
				mov al,0
				int 21h		
				
prog           ends
end start