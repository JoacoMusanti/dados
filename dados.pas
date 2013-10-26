{ @dados.pas                                  }
{ Programa: Juego de los dados                }
{ Alumnos: Cortez Emiliano                    }
{          Fontana Lucas                      }
{          Musanti Joaquin                    }
{ Comision 101 ISI turno mañana               }
{ Algoritmos y estructuras de datos. UTN FRRo }

program dados(input, output);

uses crt;

type
   n = string[20];

   jugador = record
      mongos     : integer;
      clavadas   : integer;
      ganadas    : integer;
      perdidas   : integer;
      jugadastot : integer;
      nombre     : n;
      colores    : array [1..5] of integer
   end;
   
   arch = file of jugador;

var
   archivo                          : arch;
   j                                : jugador;
   continuar, primero, perdio, gano : boolean;
   opcion, salida, primertiro       : integer;
   buffer                           : string;
   dado                             : array [1..2] of integer;

procedure creaArchivo;

begin
   {$I-}
   reset(archivo);
   if ioresult <> 0 then
      rewrite(archivo);
   {$I+}
   close(archivo)
end;

function buscaJugador(nombre : n) : integer;
{ Busca un jugador en el archivo por nombre }
var
   temp : jugador;
begin
   reset(archivo);

   if filesize(archivo) > 0 then
   begin
      repeat
         read(archivo, temp);
      until (eof(archivo)) or (temp.nombre = nombre);

      if temp.nombre = nombre then
         buscaJugador := filepos(archivo) - 1
      else
         buscaJugador := -1
   end
   else
      buscaJugador := -1;

   close(archivo)
end;

procedure cargaJugador;
{ Pide el nombre del jugador y verifica si está o no en el archvo }
var
   nom     : string[20];
   pos     : integer;
   colores : array [1..5] of integer;
begin
   creaArchivo;

   colores[1] := 15;                   { El color 1 es utilizado para el texto, el color default es blanco }
   colores[2] := 14;                   { El color 2 es utilizado para los numeros de las opciones de un menu, el color default es amarillo }
   colores[3] := 12;                   { El color 3 es utilizado para mostrar mensajes de error, el color default es rojo }
   colores[4] := 9;                    { El color 4 es utilizado para titulos y resaltar palabras, el color default es violeta }
   colores[5] := 10;                   { El color 5 es utilizado para resaltar palabras, el color default es verde }

   write('Nombre del jugador: ');
   readln(nom);
   clrScr;

   pos := buscaJugador(nom);

   if pos = -1 then
   begin
      j.nombre := nom;
      j.mongos := 0;
      j.clavadas := 0;
      j.ganadas := 0;
      j.perdidas := 0;
      j.jugadastot := 0;
      j.colores := colores;

      reset(archivo);
      seek(archivo, filesize(archivo));
      write(archivo, j);
      close(archivo)
   end
   else
   begin
      reset(archivo);
      seek(archivo, pos);
      read(archivo, j);
      close(archivo)
   end
end;

procedure guardaJugador(jug : jugador);
var
   pos : integer;
begin
   pos := buscaJugador(jug.nombre);

   reset(archivo);
   if pos <> -1 then
      seek(archivo, pos)
   else
      seek(archivo, filesize(archivo));

   write(archivo, jug);
   close(archivo)
end;

procedure mostrarErrorDeEntrada;
{ Este procedure es llamado siempre que el usuario ingrese un dato invalido }
begin
   gotoXY(14, 11);
   textColor(j.colores[3]);
   write('Entrada invalida');
   readKey()
end;

procedure Tiradas(jugadas : integer);
{ Este procedure analiza el puntaje obtenido luego de tirar los dados y decide }
{ si el jugador gana, pierde o sigue jugando                                   }
var
   suma : integer;
begin
   suma := dado[1] + dado[2];

   gotoxy(2, 5);

   if jugadas = 1 then
   begin
      if (suma = 7) or (suma = 11) then
      begin
         textColor(j.colores[5]);
         j.clavadas := j.clavadas + 1;
         write('!!!CLAVADA!!!  :) ');
         gano := true
      end
      else
      begin
         if (suma = 2) or (suma = 3) or (suma = 12) then
         begin
            textColor(j.colores[3]);
            j.mongos := j.mongos + 1;
            write('!!!MONGO!!! :(  ');
            perdio:= true
         end
         else
         begin
            primertiro := suma
         end
      end
   end;

   if jugadas > 1 then
   begin
      if suma = primertiro then
      begin
         textColor(j.colores[5]);
         write('!!!GANASTE!!!');
         gano:= true
      end;

      if suma = 7 then
      begin
         textColor(j.colores[3]);
         write('PERDISTE');
         perdio:= true
      end
   end;

   readKey()
end;

procedure tirarDados;
{ Este procedure "lanza" los dados a traves de la funcion random() y los imprime en pantalla }
{ dependiendo de los resultados obtenidos                                                    }
var
   i, k : integer;
begin
   dado[1] := random(6) + 1;
   dado[2] := random(6) + 1;

   for k := 0 to 1 do
   begin
      textColor(j.colores[2]);

      for i:=11 to 21 do                { Dibuja las lineas laterales del dado }
      begin
         gotoxy(10 + 30 * k,i);
         write(chr(179));
         gotoxy(30 + 30 * k,i);
         write(chr(179));
      end;

      gotoxy(11 + 30 * k, 10);          { Dibuja la linea superior del dado }
      for i := 1 to 20 do
         write(chr(196));

      gotoxy(11 + 30 * k, 21);          { Dibuja la linea inferior del dado }
      for i := 1 to 20 do
         write(chr(196));

      gotoxy(10 + 30 * k, 10);          { Dibuja las esquinas }
      write(chr(218));

      gotoxy(10 + 30 * k, 21);
      write(chr(192));

      gotoxy(30 + 30 * k, 10);
      write(chr(191));

      gotoxy(30 + 30 * k, 21);
      write(chr(217));

      textColor(j.colores[4]);

      case dado[k + 1] of                                         { Dibuja los puntos }
        1 : begin
               gotoxy(20 + 30 * k,15); write(chr(219));
            end;

        2 : begin
               gotoxy(15 + 30 * k,13); write(chr(219));
               gotoxy(25 + 30 * k,18); write(chr(219));
            end;

        3 : begin
               gotoxy(14 + 30 * k,12); write(chr(219));
               gotoxy(20 + 30 * k,16); write(chr(219));
               gotoxy(26 + 30 * k,19); write(chr(219));
            end;

        4 : begin
               gotoxy(16 + 30 * k,13); write(chr(219));
               gotoxy(24 + 30 * k,13); write(chr(219));
               gotoxy(16 + 30 * k,18); write(chr(219));
               gotoxy(24 + 30 * k,18); write(chr(219));
            end;

        5 : begin
               gotoxy(16 + 30 * k,13); write(chr(219));
               gotoxy(24 + 30 * k,13); write(chr(219));
               gotoxy(16 + 30 * k,19); write(chr(219));
               gotoxy(24 + 30 * k,19); write(chr(219));
               gotoxy(20 + 30 * k,16); write(chr(219));
            end;

        6 : begin
               gotoxy(15 + 30 * k,13); write(chr(219));
               gotoxy(25 + 30 * k,13); write(chr(219));
               gotoxy(15 + 30 * k,19); write(chr(219));
               gotoxy(25 + 30 * k,19); write(chr(219));
               gotoxy(15 + 30 * k,16); write(chr(219));
               gotoxy(25 + 30 * k,16); write(chr(219));
            end;
      end
   end
end;

procedure jugar;
{ Este procedure se llama cuando el usuario desea iniciar el juego, se ejecuta hasta que el jugador }
{ gane o pierda                                                                                     }
var
   jugadas : integer;
begin
   perdio := false;
   gano := false;
   primero := true;
   jugadas := 1;

   repeat
      repeat
         if not primero then
            mostrarErrorDeEntrada;

         clrScr;

         textColor(j.colores[1]);
         gotoXY(1,1);
         write(' Tirada N# ');
         textColor(j.colores[4]);
         writeln(jugadas);
         textColor(j.colores[1]);

         if jugadas > 1 then
            writeln(' Si sacas ', primertiro, ', ganas!');

         write(' Ingrese 1 para tirar o 2 para salir: ');
         readln(buffer);

         val(buffer, opcion, salida);

         primero := false

      until (salida = 0) and (opcion >= 1) and (opcion <= 2);

      primero := true;

      if (opcion = 1) then
      begin
         tirarDados;
         Tiradas(jugadas)
      end
      else
         perdio := true;

      jugadas := jugadas + 1;

   until (perdio) or (gano);

   j.jugadastot := j.jugadastot + 1;

   if perdio then
      j.perdidas := j.perdidas + 1
   else
      j.ganadas := j.ganadas + 1;

   guardaJugador(j)
end;

procedure mostrarMenuColores;
{ Este procedure muestra un menu con los colores utilizados actualmente, y le da la posibilidad }
{ al usuario de modificar alguno de ellos                                                       }
var
   i : integer;
begin
   clrScr;

   primero := true;

   gotoXY(3, 1);
   textColor(j.colores[1]);
   write('Seleccione un color a modificar');

   for i := 1 to 5 do
   begin
      gotoXY(3, i + 3);
      textColor(j.colores[2]);
      writeln(i);

      textColor(j.colores[1]);
      gotoXY(4, i + 3);
      write(') Color ', i, ' = ');
      textColor(j.colores[i]);
      write(chr(219), chr(219), chr(219), chr(219))
   end;

   textColor(j.colores[2]);
   gotoXY(3, 9);
   write('6');
   textColor(j.colores[1]);
   write(') Atras');
   gotoXY(11, 10);
   write('Opcion: ');
end;

procedure mostrarPosiblesColores;
{ Le presenta al usuario un menu con los 15 posibles colores a elegir      }
{ El color elegido en este menu reemplazara al elegido en el menu anterior }
var
   i, viejoColor : integer;
begin
   primero := true;

   viejoColor := opcion;

   repeat
      if not primero then
         mostrarErrorDeEntrada;

      clrScr;

      textColor(j.colores[1]);
      gotoXY(3, 1);
      write('Reemplazar al color ');
      textColor(j.colores[viejoColor]);
      write(chr(219), chr(219), chr(219), chr(219));
      textColor(j.colores[1]);
      write(' por alguno de los siguientes');

      for i := 1 to 15 do
      begin
         gotoXY(3, i + 3);
         textColor(j.colores[2]);
         write(i);
         textColor(j.colores[1]);

         if i < 10 then
            write(')  ')
         else
            write(') ');

         textColor(i);
         write(chr(219), chr(219), chr(219), chr(219))
      end;

      textColor(j.colores[1]);
      gotoXY(11, 19);
      write('Opcion: ');
      readln(buffer);
      val(buffer, opcion, salida);

      primero := false
   until (salida = 0) and (opcion >= 1) and (opcion <= 15);

   j.colores[viejoColor] := opcion;

   primero := true
end;

procedure cambiarColores;
{ Este procedure llama al procedure mostrarMenuColores, el color elegido en ese procedure }
{ sera reemplazado por el color elegido en mostrarPosiblesColores                         }
begin
   continuar := true;

   repeat
      primero := true;

      repeat
         if not primero then
            mostrarErrorDeEntrada;

         mostrarMenuColores;
         readln(buffer);
         val(buffer, opcion, salida);

         primero := false
      until (salida = 0) and (opcion >= 1) and (opcion <= 6);

      if opcion = 6 then
         continuar := false
      else
         mostrarPosiblesColores

      until continuar = false;

   guardaJugador(j);
   continuar := true;
   primero := true
end;

procedure mostrarMenu;
{ Este procedure muestra el menu principal }
var
   i : integer;
begin
   clrScr;

   gotoXY(15,1);
   textColor(j.colores[4]);
   write('Juego de dados');

   textColor(j.colores[2]);

   for i := 1 to 5 do
   begin
      gotoXY(3, i + 2);
      writeln(i);
   end;

   textColor(j.colores[1]);
   gotoXY(4, 3);
   write(') Jugar');
   gotoXY(4, 4);
   write(') Estadisticas');
   gotoXY(4, 5);
   write(') Ayuda');
   gotoXY(4, 6);
   write(') Colores');
   gotoXY(4, 7);
   write(') Salir');
   gotoXY(11, 8);
   write('Opcion: ')
end;

procedure mostrarAyuda;
{ Este procedure imprime en pantalla las instrucciones del juego }
begin
   clrScr;

   textColor(j.colores[4]);
   writeln();
   writeln('  Instrucciones de juego');
   writeln();
   textColor(j.colores[1]);
   writeln('  El juego consiste en lanzar 2 dados, y segun el resultado se gana o se pierde: ');
   textColor(j.colores[4]);
   writeln('  Primera vez a lanzar:');
   textColor(j.colores[5]);
   write('  SE PIERDE');
   textColor(j.colores[1]);
   writeln(': Si el resultado de la suma da:  2 o 3 o 12. (Se le llama MONGO)');
   textColor(j.colores[5]);
   write('  SE GANA');
   textColor(j.colores[1]);
   writeln(': Si el resultado de la suma da: 7 u 11. (Se le llama CLAVADA)');
   textColor(j.colores[5]);
   write('  SEGUIS TIRANDO');
   textColor(j.colores[1]);
   writeln(': Si el resultado de la suma da: 4 o 5 o 6 u 8 o 9 o 10.');
   textColor(j.colores[4]);
   writeln('  Al tirar nuevamente');
   textColor(j.colores[5]);
   write('  SE PIERDE');
   textColor(j.colores[1]);
   writeln(': Si el resultado de la suma da: 7.');
   textColor(j.colores[5]);
   write('  SE GANA');
   textColor(j.colores[1]);
   writeln(': Si el resultado de la suma da: El mismo numero que tiraste al lanzar');
   writeln('  la primera vez.');
   textColor(j.colores[5]);
   write('  SEGUIS TIRANDO');
   textColor(j.colores[1]);
   writeln(': Si el resultado de la suma da: Cualquier numero distinto de 7');
   writeln('  y del numero que tiraste en la primera vez.');
   writeln('  Al tirar nuevamente:');
   textColor(j.colores[5]);
   write('  SE PIERDE');
   textColor(j.colores[1]);
   writeln(': Si el resultado de la suma da 7.');
   textColor(j.colores[5]);
   write('  SE GANA');
   textColor(j.colores[1]);
   writeln(': Si el resultado de la suma da: El mismo numero que tiraste al lanzar');
   writeln('  la primera vez.');
   textColor(j.colores[5]);
   write('  SEGUIS TIRANDO');
   textColor(j.colores[1]);
   writeln(': Si el resultado de la suma da: Cualquier numero distinto de 7');
   writeln('  y del numero que');
   writeln('  tiraste en la primera vez');
   writeln('  Si el jugador sale de la partida antes de terminarla,');
   writeln('  la partida se dara por perdida');
   writeln();
   writeln('  Presione cualquier tecla para salir');

   readKey()
end;

procedure mostrarPuntajes;
{ Este procedure muestra las estadisticas del jugador }
var
   temp  : jugador;
   color : integer;
begin
   clrScr;
   writeln();
   reset(archivo);

   while not eof(archivo) do
   begin
      read(archivo, temp);
      if j.nombre <> temp.nombre then
         color := j.colores[1]
      else
         color := j.colores[2];

      writeln();
      textColor(j.colores[1]);
      write('Nombre: ');
      textColor(color);
      writeln(temp.nombre);
      textColor(j.colores[5]);
      write('      Ganadas: ');
      textColor(color);
      writeln(temp.ganadas);
      textColor(j.colores[5]);
      write('         Clavadas: ');
      textColor(color);
      writeln(temp.clavadas);
      textColor(j.colores[5]);
      write('      Perdidas: ');
      textColor(color);
      writeln(temp.perdidas);
      textColor(j.colores[5]);
      write('         Mongos: ');
      textColor(color);
      writeln(temp.mongos);
      textColor(j.colores[5]);
      write('      Tiradas: ');
      textColor(color);
      writeln(temp.jugadastot)
   end;

   close(archivo);
   writeln();
   textColor(j.colores[1]);
   write(' Presione una tecla para salir');
   readKey()
end;

procedure dibujarLogo;
var
   i : integer;
begin
   textColor(10);
   gotoxy(30,7);write(chr(223));

   for i:= 1 to 10 do
      write(chr(223));

   gotoxy(40,7);write(chr(223));

   for i:= 8 to 12 do
   begin
      gotoxy(30,i);
      write(chr(223));
      gotoxy(40,i);
      write(chr(223));
   end;

   gotoxy(30,13);write(chr(223));

   for i:= 1 to 10 do
      write(chr(223));

   gotoxy(40,13);write(chr(223));

   textColor(12);

   gotoxy(25,5);write(chr(223));

   for i:= 1 to 8 do
      write(chr(223));

   for i:= 5 to 10 do
   begin
      gotoxy(25,i);
      write(chr(223))
   end;

   gotoxy(26,10);write(chr(223));
   for i:= 1 to 3 do
      write(chr(223));
   for i:= 5 to 6 do

   begin
      gotoxy(33,i);
      write(chr(223))
   end;

   gotoxy(39,6);write('CLAVADA');

   textColor(9);

   gotoxy(37,5);write(chr(223));

   for i:= 1 to 8 do
      write(chr(223));
   for i:= 5 to 6 do

   begin
      gotoxy(37,i);
      write(chr(223))
   end;

   gotoxy(41,10);write(chr(223));

   for i:= 1 to 4 do
      write(chr(223));
   for i:= 5 to 10 do

   begin
      gotoxy(46,i);
      write(chr(223))
   end;
   gotoxy(27,6);write('MONGO');

   textColor(12);
   Gotoxy(33,9);write('JUEGO');
   Gotoxy(33,10);write('DE LOS');
   Gotoxy(33,11);write('DADOS');
end;

procedure inicializacion;
{ Este procedure le da los valores iniciales a las variables }
begin
   assign(archivo, 'jugadores.dat');
   randomize;
   
   continuar := true;

   cargaJugador;
end;

{ Programa principal }
begin
   inicializacion;
   dibujarLogo;
   delay(3500);
   primero := true;

   repeat
      repeat
         if not primero then
            mostrarErrorDeEntrada;

         mostrarMenu;
         readln(buffer);
         val(buffer, opcion, salida);

         primero := false

      until (salida = 0) and (opcion >= 1) and (opcion <= 5);

      primero := true;

      case opcion of
        1 : begin
               jugar
            end;
        2 : begin
               mostrarPuntajes
            end;
        3 : begin
               mostrarAyuda
            end;
        4 : begin
               cambiarColores
            end;
        5 : begin
               continuar := false
            end
      end;

   until continuar = false
end.


