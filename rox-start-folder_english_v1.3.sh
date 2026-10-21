#!/bin/bash
# ROX Start Folder 1.4 — EasyOS — pp4mnk
set -eu
BASE=/usr/local/lib/rox-start-folder
CONF=${XDG_CONFIG_HOME:-$HOME/.config}/rox-start-folder
SELF=$BASE/utility
msg() {
 if command -v Xdialog >/dev/null; then Xdialog --title 'ROX · Start Folder' --msgbox "$1" 0 0
 elif command -v zenity >/dev/null; then zenity --info --title='ROX · Start Folder' --text="$1"
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
choose() {
 local folder current=/files
 if [ -f "$CONF/folder" ]; then IFS= read -r current < "$CONF/folder" || true; fi
 [ -d "$current" ] || current=/files
 if command -v Xdialog >/dev/null; then
  folder=$(Xdialog --stdout --title 'Choose the ROX start folder' --dselect "${current%/}/" 28 85) || return 0
 elif command -v zenity >/dev/null; then
  folder=$(zenity --file-selection --directory --title='ROX start folder' --filename="${current%/}/") || return 0
 else msg 'Xdialog or zenity is required to use the folder chooser.'; return 1; fi
 case "$folder" in /*) ;; *) msg 'Select an absolute path.'; return 1;; esac
 case "$folder" in *$'\n'*|*$'\r'*) msg 'Line breaks are not allowed in the path.'; return 1;; esac
 [ -d "$folder" ] || { msg 'The folder does not exist or is not accessible.'; return 1; }
 mkdir -p "$CONF"
 printf '%s\n' "$folder" > "$CONF/folder.tmp"
 mv -f "$CONF/folder.tmp" "$CONF/folder"
 msg "Start folder saved:\n$folder\n\nIf it is unavailable, /files will open instead."
}
settings() {
 local action current
 while :; do
  current='Default (/files)'
  if [ -f "$CONF/folder" ]; then IFS= read -r current < "$CONF/folder" || true; fi
  if command -v Xdialog >/dev/null; then
   action=$(Xdialog --stdout --title 'ROX · Start Folder' --menu "Current folder: $current" 19 85 5 choose 'Choose folder' test 'Open ROX to test' restore 'Restore /files' close 'Close') || return 0
  elif command -v zenity >/dev/null; then
   action=$(zenity --list --title='ROX · Start Folder' --text="Current folder: $current" --column=Action choose test restore close --height=330 --width=550) || return 0
  else msg 'Xdialog or zenity is required. You can also use: rox-start-folder --set /path'; return 1; fi
  case "$action" in
   choose) choose;;
   test) "$SELF" --open >/dev/null 2>&1 & ;;
   restore) rm -f "$CONF/folder"; msg 'Default folder restored: /files.';;
   *) return 0;;
  esac
 done
}
refresh() {
 if command -v fixmenus >/dev/null; then fixmenus >/dev/null 2>&1 || true; fi
 if command -v jwm >/dev/null && [ -n "${DISPLAY:-}" ]; then jwm -reload >/dev/null 2>&1 || true; fi
}
install_app() {
 [ "$(id -u)" = 0 ] || { msg 'Install this utility as root.'; exit 1; }
 local bin sourcepath file line replacement n=0 saved_id
 bin=$(command -v rox || command -v ROX-Filer || true)
 [ -n "$bin" ] || { msg 'ROX-Filer was not found.'; exit 1; }
 if [ ! -f "$BASE/rox-path" ]; then
 for file in /usr/local/bin/rox-start-folder /usr/share/applications/rox-start-folder.desktop /usr/share/applications/rox-start-open.desktop; do
  [ ! -e "$file" ] || { msg "$file already exists; installation cancelled."; exit 1; }
 done
 fi
 sourcepath=$(readlink -f "$0")
 mkdir -p "$BASE/backups" /usr/local/bin /usr/share/applications
 if [ "$sourcepath" != "$(readlink -f "$SELF")" ]; then cp "$sourcepath" "$SELF"; fi
 chmod 755 "$SELF"
 # Use an absolute icon path: menu icons must not depend on theme lookup.
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
 # Integrate the desktop's default file-manager launcher, preserving explicit arguments.
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
 # Repair existing installations too; retain the first original backup.
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
 # JWM/fixmenus may pass desktop field codes literally. Repair old launchers.
 while IFS=$'\t' read -r n file; do
  [ -n "$n" ] && [ -f "$file" ] || continue
  if grep -Eq '^Exec=/usr/local/bin/rox-start-folder --open %[fFuU][[:space:]]*$' "$file"; then
   sed 's|^Exec=/usr/local/bin/rox-start-folder --open %[fFuU][[:space:]]*$|Exec=/usr/local/bin/rox-start-folder --open|' "$file" > "$BASE/rewrite"
   cat "$BASE/rewrite" > "$file"
   cp "$file" "$BASE/desktop-$n.installed"
  fi
 done < "$BASE/desktop-list"
 rm -f "$BASE/rewrite"
 # Confirm the exact menu entry observed on EasyOS.
 file=/usr/share/applications/ROX-Filer.desktop
 if [ -f "$file" ] && ! grep -q '^Exec=/usr/local/bin/rox-start-folder --open' "$file"; then
  msg "The entry $file has a custom command and has been preserved. Use ROX - Open Start Folder."
 fi
 cat > /usr/share/applications/rox-start-folder.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=ROX - Start Folder
Comment=Choose the file manager start folder
Exec=/usr/local/bin/rox-start-folder --settings
Icon=/usr/local/lib/rox-start-folder/folder.xpm
Terminal=false
Categories=X-Filesystem;
EOF
 cat > /usr/share/applications/rox-start-open.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=ROX - Open Start Folder
Exec=/usr/local/bin/rox-start-folder --open
Icon=/usr/local/lib/rox-start-folder/folder.xpm
Terminal=false
Categories=X-Filesystem;
EOF
 refresh
 msg 'Installed or updated. Look for ROX - Start Folder in the menu.\n\nTo uninstall, run:\nrox-start-folder --uninstall'
 settings
}
uninstall_app() {
 [ "$(id -u)" = 0 ] || { msg 'Run the uninstaller as root.'; exit 1; }
 local n file conflict=0
 if [ -f "$BASE/defaultfilemanager.installed" ] && ! cmp -s /usr/local/bin/defaultfilemanager "$BASE/defaultfilemanager.installed"; then conflict=1; fi
 while IFS=$'\t' read -r n file; do
  [ -n "$n" ] || continue
  if ! cmp -s "$file" "$BASE/desktop-$n.installed"; then conflict=1; fi
 done < "$BASE/desktop-list"
 if [ "$conflict" = 1 ]; then
  msg "Some launchers have changed since installation. The utility and backups have been kept in $BASE. Review those changes before trying to uninstall again."
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
 msg 'Utility uninstalled and original launchers restored.'
}
case "${1:-}" in
 --open) shift; open_rox "$@";;
 --settings) settings;;
 --set) [ "$#" = 2 ] && [ -d "$2" ] && [[ "$2" = /* ]] && [[ "$2" != *$'\n'* ]] || exit 1; mkdir -p "$CONF"; printf '%s\n' "$2" > "$CONF/folder";;
 --restore) rm -f "$CONF/folder";;
 --uninstall) uninstall_app;;
 --install|'') install_app;;
 *) printf 'Usage: %s [--install|--settings|--open [path...]|--set /path|--restore|--uninstall]\n' "$0"; exit 1;;
esac
