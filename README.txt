ROSE Mod Launcher v1.0
======================
A launcher for ROSE Online with the game's news, one-click auto-login
buttons, a UI theme picker and a mods list. Built on ROSE Login Manager v1.9
by zeropoke - your saved logins and clients carry over as they are.


SETTING IT UP (once)
--------------------
1. Close the game.

2. Open "Copy into your ROSE Online folder" and copy everything inside it
   (the "Data" and "Launcher Mods" folders) into your ROSE Online game
   folder. Say yes to replacing files.
   - "Data" puts the game's own UI files back, so the launcher starts from
     a clean game.
   - "Launcher Mods" holds the Steampunk UI as a mod.

3. Put the "Launcher" folder anywhere you like (the game folder, your
   desktop...). Keep "ROSE Mod Launcher.exe" and "Launcher Files" together.

4. Start "ROSE Mod Launcher.exe". If it asks to remove the old in-game theme
   switch (Data\ui\themes\rose\_themes), say Yes.

5. Pick "Steampunk UI" under UI Theme. That's it.

If Windows or your antivirus won't run the exe, install AutoHotkey v2
(autohotkey.com) and double-click "ROSE Mod Launcher.ahk" instead - it is
the same program as plain text.


USING IT
--------
Top bar      Website, Forum, Support, Power Up! open those pages.
             Settings manages your auto-login buttons.
             Drag the window by any empty spot. _ minimises, X closes.
News         The latest posts from roseonlinegame.com/news. Click a notice
             to show it, click the picture or its title to read it.
             Pictures are saved, so the last news still shows offline.
Client       Which game install to use (Add/Remove ROSE is at the bottom).
Update Game  Patches the game right here - no Rednim window. The launcher
             also does this by itself every time it opens (turn that off in
             Settings). START and login buttons wait for it to finish.
UI Theme     Default (the game's own look) or any theme mod.
Mods         Turn mods on and off, check for updates, open the mods folder.
Login strip  Your auto-login buttons. Click one to log straight in.
START        Opens the game normally, without logging in - the same way the
             official updater does.
>            The extra options from the old More window (export/import
             logins, dark mode, Fix XML, resets).

GAME UPDATES
------------
The launcher runs the game's own rose-updater.exe hidden in the background
(it has a built-in hidden mode for this) and shows its progress in the
launcher's bar, so the official patching is still what updates your files
- only the window is gone. rose-updater.exe has to stay in the game folder.
If an update goes wrong, the launcher offers to open the normal updater, and
what the updater said is saved in %AppData%\RLM\patch.log.

Mods are copied into the game when you change them or press START / a
login button, and the game's own files are kept in Launcher Mods\_backup
while a mod is on. Turning a mod off puts them back. If a game patch
replaces a file, the launcher notices and puts the mod back on top.
Restart the game to see a theme or mod change.


MAKING A MOD
------------
A mod is a folder inside "Launcher Mods" in the game folder:

  Launcher Mods\
    My Mod\
      mod.ini
      files\            laid out exactly like the game folder, e.g.
        Data\ui\themes\rose\game\chat_box.html

mod.ini:
  [Mod]
  Name=My Mod
  Version=1.0
  Author=you
  Group=            leave empty, or "UI Theme" for a full theme (only one
                    mod per Group can be on at a time)
  Description=What it does. Use \n for a new line.
  Priority=50       higher goes on top when two mods change the same file
  UpdateUrl=        see below

Folders starting with _ are ignored.


AUTOMATIC UPDATES (GitHub)
--------------------------
1. Open Mods, pick your mod and press "Make Update List". This writes
   manifest.txt in the mod's folder (a list of every file and its
   fingerprint).
2. Upload the whole mod folder (mod.ini, manifest.txt, files) to a public
   GitHub repo.
3. Put the raw link of manifest.txt in mod.ini, for example
     UpdateUrl=https://raw.githubusercontent.com/<you>/<repo>/main/My Mod/manifest.txt
   and upload mod.ini again (and press Make Update List once more first).

Each time the launcher opens it checks every mod that has an UpdateUrl and
downloads only the files that changed (and removes files the mod no longer
has). If the mod is on, the new files go into the game straight away.

To publish a fix: change the file, raise Version in mod.ini, press Make
Update List, upload. GitHub can take a few minutes to serve the new files.


UPDATING THE LAUNCHER ITSELF (GitHub)
-------------------------------------
The launcher checks for a newer version of itself every time it opens,
and asks before updating. It then downloads the changed files, swaps
them in and restarts.

To set it up:
1. Upload the "Launcher" folder (ROSE Mod Launcher.exe, ROSE Mod
   Launcher.ahk, Launcher Files) to a public GitHub repo.
2. In Settings press "Make Launcher Update List". This writes manifest.txt
   next to the exe - upload it into the same folder on GitHub.
3. Open Launcher Files\update.ini and put the raw link of that manifest.txt
   after Url=, for example
     Url=https://raw.githubusercontent.com/<you>/<repo>/main/Launcher/manifest.txt
   Give this update.ini to anyone else using the launcher (it is not part
   of the updates itself, so each person's link stays as they set it).

To publish a new version: raise Version at the top of the launcher script
(Version := "1.1"), rebuild the exe, press "Make Launcher Update List",
and upload the changed files plus manifest.txt. Only a version number
higher than the one someone has is offered to them.
"Check for Launcher Update" in Settings checks straight away.


CHANGING THE ICON
-----------------
The exe carries the miner's-helmet icon. "Launcher Files\ROSE Mod
Launcher.ico" is the same icon as a normal .ico file. To use a different
one, open the exe in the free Resource Hacker (angusj.com/resourcehacker),
go to Icon Group > 159, choose Action > Replace Icon, pick your .ico, and
save. For just a desktop shortcut: right-click it > Properties > Change Icon.
Windows sometimes keeps showing the old icon for a while - restarting
Explorer (or the PC) refreshes it.


WHERE THINGS ARE KEPT
---------------------
%AppData%\RLM\            logins (encrypted), clients, settings, news cache
<game>\Launcher Mods\     mods, which ones are on, and the backups
