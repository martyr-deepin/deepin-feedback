/**
 * Copyright (c) 2015 Deepin, Inc.
 *
 * Author:      Xu FaSheng <fasheng.xu@gmail.com>
 * Maintainer:  Xu FaSheng <fasheng.xu@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, see <http://www.gnu.org/licenses/>.
 **/

package main

import (
	"os"
	"pkg.linuxdeepin.com/lib"
	"pkg.linuxdeepin.com/lib/dbus"
	. "pkg.linuxdeepin.com/lib/gettext"
	"pkg.linuxdeepin.com/lib/log"
	"time"
)

var logger = log.NewLogger(dbusDest)

func main() {
	InitI18n()
	Textdomain("deepin-feedback")
	initCategories()

	if !lib.UniqueOnSystem(dbusDest) {
		logger.Warning("dbus interface already exists", dbusDest)
		return
	}
	fd := NewFeedbackDaemon()
	if err := dbus.InstallOnSystem(fd); err != nil {
		logger.Error("register dbus interface failled", err)
		return
	}

	dbus.SetAutoDestroyHandler(60*time.Second, func() bool {
		return !fd.isInWorking()
	})
	dbus.DealWithUnhandledMessage()
	if err := dbus.Wait(); err != nil {
		logger.Error("lost dbus session", err)
		os.Exit(1)
	}
}
