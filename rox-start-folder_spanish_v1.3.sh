#!/bin/bash
# ROX Carpeta inicial 1.4 — EasyOS — pp4mnk
set -eu
BASE=/usr/local/lib/rox-start-folder
CONF=${XDG_CONFIG_HOME:-$HOME/.config}/rox-start-folder
SELF=$BASE/utility
msg() {
 if command -v Xdialog >/dev/null; then Xdialog --title 'ROX · Carpeta inicial' --msgbox "$1" 0 0
 elif command -v zenity >/dev/null; then zenity --info --title='ROX · Carpeta inicial' --text="$1"
 else printf '%s\n' "$1"; fi
}
real_rox() { cat "$BASE/rox-path"; }
open_rox() {
 local bin target
 bin=$(real_rox)
 if [ "$#" -gt 0 ]; then exec "$bin" "$@"; fi
 target=/files
 if [ -f "$CONF/folder" ]; then IFS= read -r target < "$CONF/folder" || true; fi
 [ -d "$target" ] || target=/files
 [ -d "$target" ] || target=$HOME
 exec "$bin" "$target"
}
elegir() {
 local folder current=/files
 if [ -f "$CONF/folder" ]; then IFS= read -r current < "$CONF/folder" || true; fi
 [ -d "$current" ] || current=/files
 if command -v Xdialog >/dev/null; then
  folder=$(Xdialog --stdout --title 'Elige la carpeta inicial de ROX' --dselect "${current%/}/" 28 85) || return 0
 elif command -v zenity >/dev/null; then
  folder=$(zenity --file-selection --directory --title='Carpeta inicial de ROX' --filename="${current%/}/") || return 0
 else msg 'Necesitas Xdialog o zenity para utilizar el selector.'; return 1; fi
 case "$folder" in /*) ;; *) msg 'Selecciona una ruta absoluta.'; return 1;; esac
 case "$folder" in *$'\n'*|*$'\r'*) msg 'No se admiten saltos de línea en la ruta.'; return 1;; esac
 [ -d "$folder" ] || { msg 'La carpeta no existe o no está accesible.'; return 1; }
 mkdir -p "$CONF"
 printf '%s\n' "$folder" > "$CONF/folder.tmp"
 mv -f "$CONF/folder.tmp" "$CONF/folder"
 msg "Carpeta inicial guardada:\n$folder\n\nSi no está disponible, se abrirá /files."
}
settings() {
 local action current
 while :; do
  current='Predeterminada (/files)'
  if [ -f "$CONF/folder" ]; then IFS= read -r current < "$CONF/folder" || true; fi
  if command -v Xdialog >/dev/null; then
   action=$(Xdialog --stdout --title 'ROX · Carpeta inicial' --menu "Carpeta actual: $current" 19 85 5 elegir 'Elegir carpeta' probar 'Abrir ROX y probar' restaurar 'Restaurar /files' salir 'Cerrar') || return 0
  elif command -v zenity >/dev/null; then
   action=$(zenity --list --title='ROX · Carpeta inicial' --text="Carpeta actual: $current" --column=Acción elegir probar restaurar salir --height=330 --width=550) || return 0
  else msg 'Necesitas Xdialog o zenity. También puedes usar: rox-start-folder --set /ruta'; return 1; fi
  case "$action" in
   elegir) elegir;;
   probar) "$SELF" --open >/dev/null 2>&1 & ;;
   restaurar) rm -f "$CONF/folder"; msg 'Restaurada la carpeta predeterminada: /files.';;
   *) return 0;;
  esac
 done
}
refresh() {
 if command -v fixmenus >/dev/null; then fixmenus >/dev/null 2>&1 || true; fi
 if command -v jwm >/dev/null && [ -n "${DISPLAY:-}" ]; then jwm -reload >/dev/null 2>&1 || true; fi
}
install_app() {
 [ "$(id -u)" = 0 ] || { msg 'Instala esta utilidad como root.'; exit 1; }
 local bin sourcepath file line replacement n=0 saved_id
 bin=$(command -v rox || command -v ROX-Filer || true)
 [ -n "$bin" ] || { msg 'No se encuentra ROX-Filer.'; exit 1; }
 if [ ! -f "$BASE/rox-path" ]; then
 for file in /usr/local/bin/rox-start-folder /usr/share/applications/rox-start-folder.desktop /usr/share/applications/rox-start-open.desktop; do
  [ ! -e "$file" ] || { msg "Ya existe $file; instalación cancelada."; exit 1; }
 done
 fi
 sourcepath=$(readlink -f "$0")
 mkdir -p "$BASE/backups" /usr/local/bin /usr/share/applications
 if [ "$sourcepath" != "$(readlink -f "$SELF")" ]; then cp "$sourcepath" "$SELF"; fi
 chmod 755 "$SELF"
 # Usar una ruta absoluta para no depender del tema de iconos.
 cat > "$BASE/folder.xpm" <<'ROX_ICON'
/* XPM */
static char * rox_start_folder_xpm[] = {
"32 32 6 1",
"  c None",
"o c #124970",
"b c #2384B8",
"c c #9BE5FF",
"a c #53BCEB",
"l c #C5F2FF",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                ",
"  ooooooooooooo                 ",
"  obbbbbbbbbbbo                 ",
"  obbbbbbbbbbbo                 ",
"  obbbbbbbbbbbo                 ",
"  obbbbbbbbbbbbbbbbbbbbbbbbbbo  ",
"  obccccccccccccccccccccccccbo  ",
"  obccccccccccccccccccccccccbo  ",
"  obccccccccccccccccccccccccbo  ",
"  oballllllllllllllllllllllabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obaaaaaaaaaaaaaaaaaaaaaaaabo  ",
"  obbbbbbbbbbbbbbbbbbbbbbbbbbo  ",
"  oooooooooooooooooooooooooooo  ",
"                                ",
"                                ",
"                                ",
"                                ",
"                                "
};
ROX_ICON
 chmod 644 "$BASE/folder.xpm"
 printf '%s\n' "$bin" > "$BASE/rox-path"
 cat > /usr/local/bin/rox-start-folder <<'EOF'
#!/bin/sh
exec /usr/local/lib/rox-start-folder/utility "$@"
EOF
 chmod 755 /usr/local/bin/rox-start-folder
 # Integrar el lanzador predeterminado y conservar los argumentos explícitos.
 file=/usr/local/bin/defaultfilemanager
 if [ -f "$file" ] && [ ! -f "$BASE/backups/defaultfilemanager" ]; then
  cp -p "$file" "$BASE/backups/defaultfilemanager"
  cat > "$file" <<'EOF'
#!/bin/sh
if [ "$#" -gt 0 ]; then
 exec /usr/local/lib/rox-start-folder/backups/defaultfilemanager "$@"
fi
exec /usr/local/lib/rox-start-folder/utility --open
EOF
  chmod 755 "$file"
  cp "$file" "$BASE/defaultfilemanager.installed"
 fi
 # Reparar instalaciones anteriores y conservar la primera copia original.
 touch "$BASE/desktop-list"
 for file in /usr/share/applications/*.desktop; do
  [ -f "$file" ] || continue
  if LC_ALL=C awk '
   /^[[:space:]]*Exec[[:space:]]*=/ {
    sub(/\r$/, ""); sub(/^[[:space:]]*Exec[[:space:]]*=[[:space:]]*/, "")
    if ($0 ~ /^(\/usr\/(local\/)?bin\/)?(rox|ROX-Filer)([[:space:]]+%[fFuU])?[[:space:]]*$/) found=1
   }
   END {exit !found}' "$file"; then
   saved_id=$(awk -F '\t' -v path="$file" '$2==path {print $1; exit}' "$BASE/desktop-list")
   if [ -z "$saved_id" ]; then
    n=$(awk -F '\t' 'BEGIN {max=0} $1+0>max {max=$1+0} END {print max+1}' "$BASE/desktop-list")
    cp -p "$file" "$BASE/backups/desktop-$n"
    printf '%s\t%s\n' "$n" "$file" >> "$BASE/desktop-list"
   else n=$saved_id; fi
   awk '
    /^[[:space:]]*Exec[[:space:]]*=/ {
     original=$0; sub(/\r$/, ""); sub(/^[[:space:]]*Exec[[:space:]]*=[[:space:]]*/, "")
     if ($0 ~ /^(\/usr\/(local\/)?bin\/)?(rox|ROX-Filer)([[:space:]]+%[fFuU])?[[:space:]]*$/)
      $0="Exec=/usr/local/bin/rox-start-folder --open"
     else $0=original
    } {print}' "$file" > "$BASE/rewrite"
   cat "$BASE/rewrite" > "$file"
   cp "$file" "$BASE/desktop-$n.installed"
  fi
 done
 rm -f "$BASE/rewrite"
 # JWM/fixmenus puede pasar marcadores literalmente. Reparar los lanzadores antiguos.
 while IFS=$'\t' read -r n file; do
  [ -n "$n" ] && [ -f "$file" ] || continue
  if grep -Eq '^Exec=/usr/local/bin/rox-start-folder --open %[fFuU][[:space:]]*$' "$file"; then
   sed 's|^Exec=/usr/local/bin/rox-start-folder --open %[fFuU][[:space:]]*$|Exec=/usr/local/bin/rox-start-folder --open|' "$file" > "$BASE/rewrite"
   cat "$BASE/rewrite" > "$file"
   cp "$file" "$BASE/desktop-$n.installed"
  fi
 done < "$BASE/desktop-list"
 rm -f "$BASE/rewrite"
 # Comprobar la entrada del menú de EasyOS.
 file=/usr/share/applications/ROX-Filer.desktop
 if [ -f "$file" ] && ! grep -q '^Exec=/usr/local/bin/rox-start-folder --open' "$file"; then
  msg "La entrada $file tiene una orden personalizada. Se ha conservado. Usa ROX - Abrir carpeta inicial."
 fi
 cat > /usr/share/applications/rox-start-folder.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=ROX - Carpeta inicial
Comment=Elegir la carpeta de inicio del gestor de archivos
Exec=/usr/local/bin/rox-start-folder --settings
Icon=/usr/local/lib/rox-start-folder/folder.xpm
Terminal=false
Categories=X-Filesystem;
EOF
 cat > /usr/share/applications/rox-start-open.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=ROX - Abrir carpeta inicial
Exec=/usr/local/bin/rox-start-folder --open
Icon=/usr/local/lib/rox-start-folder/folder.xpm
Terminal=false
Categories=X-Filesystem;
EOF
 refresh
 msg 'Instalado o actualizado. Busca «ROX - Carpeta inicial» en el menú.\n\nPuedes desinstalar con:\nrox-start-folder --uninstall'
 settings
}
uninstall_app() {
 [ "$(id -u)" = 0 ] || { msg 'Ejecuta la desinstalación como root.'; exit 1; }
 local n file conflict=0
 if [ -f "$BASE/defaultfilemanager.installed" ] && ! cmp -s /usr/local/bin/defaultfilemanager "$BASE/defaultfilemanager.installed"; then conflict=1; fi
 while IFS=$'\t' read -r n file; do
  [ -n "$n" ] || continue
  if ! cmp -s "$file" "$BASE/desktop-$n.installed"; then conflict=1; fi
 done < "$BASE/desktop-list"
 if [ "$conflict" = 1 ]; then
  msg "Hay lanzadores modificados después de instalar. Se conservan la utilidad y sus copias en $BASE. Revisa esos cambios antes de repetir la desinstalación."
  return 1
 fi
 if [ -f "$BASE/defaultfilemanager.installed" ]; then cp -p "$BASE/backups/defaultfilemanager" /usr/local/bin/defaultfilemanager; fi
 while IFS=$'\t' read -r n file; do
  [ -n "$n" ] || continue
  cp -p "$BASE/backups/desktop-$n" "$file"
 done < "$BASE/desktop-list"
 rm -f /usr/share/applications/rox-start-folder.desktop /usr/share/applications/rox-start-open.desktop /usr/local/bin/rox-start-folder
 rm -rf "$BASE"
 refresh
 msg 'Utilidad desinstalada y lanzadores originales restaurados.'
}
case "${1:-}" in
 --open) shift; open_rox "$@";;
 --settings) settings;;
 --set) [ "$#" = 2 ] && [ -d "$2" ] && [[ "$2" = /* ]] && [[ "$2" != *$'\n'* ]] || exit 1; mkdir -p "$CONF"; printf '%s\n' "$2" > "$CONF/folder";;
 --restore) rm -f "$CONF/folder";;
 --uninstall) uninstall_app;;
 --install|'') install_app;;
 *) printf 'Uso: %s [--install|--settings|--open [ruta...]|--set /ruta|--restore|--uninstall]\n' "$0"; exit 1;;
esac
