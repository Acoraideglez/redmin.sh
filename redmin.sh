#!/bin/bash +x
#reparar confirmación de usuario en --consultar al no introducir ningun nombre
usu=$2
cat /etc/passwd | grep "$usu" > /dev/null && existe=0 || existe=1
menu=("Si""No")
[ $USER != "root" ] && echo "Debes ejecutar como root" && exit 1
ayuda() {
	echo "Este es el manual de Usermin;"
	echo "--listar; lista todos los usuarios del sistema"
	echo "--consultar (NombreUsuario); lista la información del usuario indicado"
	echo "--nuevo (NombreUsuario); Crea un nuevo usuario con el nombre indicado"
	echo "--eliminar (NombreUsuario); Elimina el usuario indicado"
	echo "-f (NombreFichero); Crea usuarios por lote a partir de los datos del fichero"
}
infousu(){
	if [ $existe -eq 1 ]
	then
		echo "El usuario no existe"
	else
		echo "Información de $usu: "
		echo -n "UID: "
		grep -w $usu /etc/passwd | cut -d: -f3
		echo -n "GID: "
		grep -w $usu /etc/passwd | cut -d: -f4
		echo -n "HOME: "
		grep -w $usu /etc/passwd | cut -d: -f6
		echo -n "SHELL: "
		grep -w $usu /etc/passwd | cut -d: -f7
	fi
}
listarusus(){
	while read usuario
	do
		uid=$(echo $usuario | cut -f3 -d:)
		if [ $uid -ge 1000 ]
		then
			username=$(echo $usuario | cut -f1 -d:)
			shel=$(echo $usuario | cut -f7 -d:)
			echo $uid,$username,$shel
		fi
	done < /etc/passwd
}
usucheck(){
	if [ -z "$usu" ]
	then
		echo "No has introducido un usuario"
		read -p "Introduce un usuario: " usu 
		infousu
	else
		infousu
	fi
}
creausu(){
	if [ -z "$usu" ]
	then
		echo "No has introducido un nombre de usuario"

	else
		if [ $existe = 0 ]
		then
			echo "El usuario $usu ya existe"
		else
			while true
			do
			read -p "Introduce el nombre del bash; " bash
			if [ -z "$bash" ]
			then
			echo "No has introducido el bash"
			else
				while true
				do
				read -p "Introduce un comentario; " comen
				if [ -z "$comen" ]
				then
					echo "Por favor introduce un comentario"
				else
					while true
					do
					read -p "Introduce la contraseña; " pass
					read -p "Confirme su contraseña; " pass2

					if [ "$pass" = "$pass2" ]
					then
						useradd -m -s /sbin/$bash -p $pass -c "$comen" $usu &> /dev/null
						echo "Usuario creado correctamente"
						exit 0
					else
						echo "Las contraseñas no coinciden"
					fi
					done
				fi
				done
			fi
			done
		fi
	fi
}
compruebausu(){
	if [ -z "$usu" ]
	then
		echo "no has introducido un usuario"
		read -p "introduzca el usuario; " usu
	fi
}
eliminausu(){
	compruebausu
	if [ $existe -eq 1 ]
	then
		echo "El usuario no existe"
	else
		while true
		do
			echo "¿Está seguro de que desea eliminar el usuario $usu?"
			echo "1. Si."
			echo "2. No."
			echo -n "Escoger opcion: "
			read opcion
			case $opcion in
			1)
				echo "eliminando el usuario $usu..."
				userdel -r "$usu" &> /dev/null
				break
			;;
			2) 
				echo "Saliendo..."
				break
			;;
			*)
				echo "opción no válida"
			;;
			esac
		done
	fi
}
#fichero(){
#	while read linea
#	do
#		
#	done < fichero_a_leer
#}

if [ $# -eq 0 ]
then
	echo "para abrir el manual introduce --help"

elif [ $1 = "--help" ]
then
	ayuda

elif [ $1 = "--consultar" ]
then
	usucheck

elif [ $1 = '--nuevo' ]
then
	creausu
elif [ $1 = "--eliminar" ]
then
	eliminausu

elif [ $1 = "--listar" ]
then
	echo "Listando usuarios..."
	listarusus
elif [ $1 = "-f" ]
then
	echo "Fichero"
else
	echo "$1 no es una opcion válida, para consultar el manual introduzca --help"
fi
