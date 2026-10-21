Rox Start Folder

https://github.com/pp4mnk/rox_start_folder

Español and English POST

ROX Start Folder: elige fácilmente en qué carpeta se abre ROX-Filer

Seguro que muchos usuarios de EasyOS han deseado alguna vez que ROX-Filer se abra directamente en su carpeta preferida: Descargas, Documentos, una carpeta de trabajo o un directorio de otro disco.

Configurar este comportamiento manualmente lleva algo de trabajo: hay que localizar el lanzador, modificar su orden de ejecución y actualizar el menú. Para simplificarlo, he preparado ROX Start Folder, un script que permite elegir la carpeta de inicio mediante una sencilla ventana.

Instalación y uso

Descarga el script y ejecuta, desde la carpeta donde lo hayas guardado:

bash rox-start-folder.sh

Después:

    Abre ROX – Carpeta inicial en el menú Filesystem.
    Pulsa Elegir carpeta y selecciona el directorio que prefieras.
    Utiliza Abrir ROX y probar para comprobar el resultado.

A partir de entonces, la entrada de ROX del menú adaptada por la utilidad abrirá directamente la carpeta seleccionada.

¿Cómo funciona?

El script no modifica el ejecutable de ROX-Filer. Instala un lanzador intermediario que consulta la carpeta guardada y se la pasa a ROX como argumento.

La selección se almacena normalmente en:

~/.config/rox-start-folder/folder

El selector gráfico utiliza Xdialog o, como alternativa, Zenity. Las rutas se pasan entre comillas, por lo que se admiten nombres de carpetas con espacios.

Durante la instalación, la utilidad adapta las entradas genéricas de ROX que reconoce, incluida la habitual ROX-Filer.desktop, y se integra con el lanzador predeterminado de archivos cuando está disponible. Sus propias entradas aparecen únicamente en Filesystem, con un icono incluido para no depender del tema de iconos instalado.

Algunos detalles prácticos

    La carpeta elegida se utiliza cuando se abre ROX sin indicar un destino.
    Los accesos que especifican una carpeta concreta conservan ese destino.
    Si la carpeta seleccionada no está disponible, intenta abrir /files y, como última alternativa, la carpeta personal.
    Puedes restaurar /files desde la ventana de configuración.
    Volver a ejecutar el instalador permite actualizar la utilidad sin perder la carpeta elegida.

El script conserva copias de los lanzadores modificados. Para desinstalarlo y restaurarlos, ejecuta:

rox-start-folder --uninstall

Los lanzadores personalizados que invoquen ROX directamente pueden necesitar una adaptación adicional.

Una pequeña utilidad para convertir una configuración manual en una elección de unos pocos clics.

Si la probáis en EasyOS Excalibur, comentad qué tal os funciona y qué mejoraríais.

pp4mnk

English

ROX Start Folder: easily choose where ROX-Filer opens

I am sure many EasyOS users have wished that ROX-Filer would open directly in a folder of their choice: Downloads, Documents, a working directory, or a folder on another drive.

You can configure this manually, but it involves finding the relevant launcher, editing its command, and refreshing the menu. To make the process easier, I have put together ROX Start Folder, a script that adds an entry under Filesystem and lets you choose your preferred folder through a simple graphical window.

How to use it

    Download the script and run bash rox-start-folder.sh from the directory containing it.
    Open ROX – Start Folder under Filesystem.
    Select Choose folder and browse to your preferred directory.
    Use Open ROX to test to check the result.

From then on, opening ROX through the menu entry adapted by the utility will use your selected folder.

Technical details

The script does not modify the ROX-Filer executable. It installs an intermediary launcher and adapts the generic ROX application entries it recognises, including the usual ROX-Filer.desktop entry. It also integrates with the default file-manager launcher when available.

Your chosen path is stored in a configuration file, normally at:

~/.config/rox-start-folder/folder

The folder chooser uses Xdialog, with Zenity as an alternative. Paths are passed as quoted arguments, allowing folder names containing spaces without interpreting their contents as executable code.

The custom start folder applies when ROX is launched without an explicit destination. Calls that supply a specific path keep that destination. If your selected folder is unavailable—for example, because its drive is not mounted—the utility falls back to /files, then to your home directory if necessary.

There is also an option to restore /files. Backups of modified launchers are retained so that the originals can be restored when uninstalling:

rox-start-folder --uninstall

A small utility that turns a manual configuration task into a few clicks. Custom shortcuts that invoke ROX directly may require an additional adjustment.
