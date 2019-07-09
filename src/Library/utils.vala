/* Copyright 2019 Andrés Segovia
*
* This file is part of GCleaner.
*
* GCleaner is free software: you can redistribute it
* and/or modify it under the terms of the GNU General Public License as
* published by the Free Software Foundation, either version 3 of the
* License, or (at your option) any later version.
*
* GCleaner is distributed in the hope that it will be
* useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
* Public License for more details.
*
* You should have received a copy of the GNU General Public License along
* with GCleaner. If not, see http://www.gnu.org/licenses/.
*/

using Gtk;
using Gdk;
using GLib;

public Pixbuf load_pixbuf (string rsc_icon, int size = 16) {
    var pix = new Gdk.Pixbuf.from_file_at_scale (rsc_icon, size, size, false);

    return pix;
}

public Image load_image (string type_icon, string name_icon, int size = 16) {
    Image image = new Image ();
    string rsc_icon = Constants.PKGDATADIR + "/media/" + type_icon + "/" + name_icon + ".png";
    try {
        var pix = load_pixbuf(rsc_icon, size);
        image.set_from_pixbuf (pix);
    } catch (Error e) {
        stderr.printf ("[GLIB::ERROR WHEN CREATING ICON]\n");
        stderr.printf (">>> Check path: " + rsc_icon + "\n");
    }

    return image;
}

public Image load_image_from_path (string path_img, int size = 16) {
    Image image = new Image ();
    try {
        var pix = load_pixbuf(path_img, size);
        image.set_from_pixbuf (pix);
    } catch (Error e) {
        stderr.printf ("[GLIB::ERROR WHEN CREATING ICON]\n");
        stderr.printf (">>> Check path: " + path_img + "\n");
    }

    return image;
}

public bool comprobe_if_exists_app (string app_name) {
    string[] items_apps = { "kde", "flash", "system" };
    if (app_name in items_apps) {
        if (app_name == "kde") {
            string current_session;
            string path_kde_temp;
            string errors;
            int status;
            try {
                Process.spawn_command_line_sync ("echo $XDG_SESSION_DESKTOP", out current_session, out errors, out status);
            } catch (GLib.SpawnError e) {
                stdout.printf ("[COMMAND-ERROR: %s]", e.message);
                stdout.printf ("[ERROR: %s]\n", errors);
                stdout.printf ("[STATUS: %s]\n", status.to_string ());
            }
            try {
                Process.spawn_command_line_sync ("readlink -f " + GLib.Environment.get_variable ("HOME") + "/.kde/ 2>/dev/null", out path_kde_temp, out errors, out status);
            } catch (GLib.SpawnError e) {
                stdout.printf ("[COMMAND-ERROR: %s]", e.message);
                stdout.printf ("[ERROR: %s]\n", errors);
                stdout.printf ("[STATUS: %s]\n", status.to_string ());
            }
            
            if (path_kde_temp != "" || current_session == "kde") {
                return true;
            } else {
                return false;
            }
        } else if (app_name == "flash") {
            string flash_ubuntu_file = "/usr/lib/flashplugin-installer/libflashplayer.so";
            string flash_adobe_file = "usr/lib/adobe-flashplugin/libflashplayer.so";
            if (FileUtilities.exists_file (flash_ubuntu_file) || FileUtilities.exists_file (flash_adobe_file)) {
                return true;
            } else {
                return false;
            }
        } else { // app_name = system
            return true;
        }
    } else {
        string app_path = "";
        string errors;
        int status;

        try {
            Process.spawn_command_line_sync ("which " + app_name + " 2>/dev/null", out app_path, out errors, out status);
        } catch (GLib.SpawnError e) {
            stdout.printf ("[COMMAND-ERROR: %s]", e.message);
            stdout.printf ("[ERROR: %s]\n", errors);
            stdout.printf ("[STATUS: %s]\n", status.to_string ());
        }
        if (app_path != "")
            return true;
        else 
            return false;
    }
}
