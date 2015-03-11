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
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"pkg.linuxdeepin.com/lib/dbus"
	. "pkg.linuxdeepin.com/lib/gettext"
	"pkg.linuxdeepin.com/lib/utils"
	"strings"
	"sync"
	"time"
)

var globalRequstID uint64 = 0

const (
	dbusDest             = "com.deepin.Feedback"
	dbusObjectPath       = "/com/deepin/Feedback"
	dbusInterface        = "com.deepin.Feedback"
	deepinFeedbackCliExe = "/usr/bin/deepin-feedback-cli"
)

type category struct {
	Value string
	Name  string
}

var categories []category

func initCategories() {
	categories = []category{
		{Value: "all", Name: Tr("All")},
		{Value: "background", Name: Tr("Background")},
		{Value: "bluetooth", Name: Tr("Bluetooth")},
		{Value: "bootmgr", Name: Tr("Boot Interface")},
		{Value: "desktop", Name: Tr("Desktop")},
		{Value: "display", Name: Tr("Display")},
		{Value: "dock", Name: Tr("Dock")},
		{Value: "launcher", Name: Tr("Launcher")},
		{Value: "login", Name: Tr("User Login Interface")},
		{Value: "network", Name: Tr("Network")},
	}
}

type FeedbackDaemon struct {
	WorkingSet             map[uint64]bool
	sorkingSetMutex        sync.Mutex
	GenerateReportFinished func(requstID uint64, files []string)
}

func NewFeedbackDaemon() (fd *FeedbackDaemon) {
	fd = &FeedbackDaemon{}
	fd.WorkingSet = make(map[uint64]bool)
	return
}

func (fd *FeedbackDaemon) GetDBusInfo() dbus.DBusInfo {
	return dbus.DBusInfo{
		Dest:       dbusDest,
		ObjectPath: dbusObjectPath,
		Interface:  dbusInterface,
	}
}

func (fd *FeedbackDaemon) addWorkingRequest(requestID uint64) {
	fd.sorkingSetMutex.Lock()
	defer fd.sorkingSetMutex.Unlock()
	fd.WorkingSet[requestID] = true
}
func (fd *FeedbackDaemon) removeWorkingRequest(requestID uint64) {
	fd.sorkingSetMutex.Lock()
	defer fd.sorkingSetMutex.Unlock()
	delete(fd.WorkingSet, requestID)
}
func (fd *FeedbackDaemon) isInWorking() bool {
	fd.sorkingSetMutex.Lock()
	defer fd.sorkingSetMutex.Unlock()
	return len(fd.WorkingSet) > 0
}

// GetCategories return all categories that deepin-bug-reporter
// supported, each category contains several keywords to help to
// searching in front-end.
func (fd *FeedbackDaemon) GetCategories() (jsonCategories string, err error) {
	jsonCategoriesBytes, err := json.Marshal(categories)
	if err != nil {
		logger.Error(err)
	}
	jsonCategories = string(jsonCategoriesBytes)
	return
}

// GenerateBugReport notify to generate bug report for target category.
func (fd *FeedbackDaemon) GenerateReport(category string) (requstID uint64, err error) {
	defer func() {
		if err := recover(); err != nil {
			logger.Error(err)
			fd.removeWorkingRequest(requstID)
		}
	}()

	globalRequstID++
	requstID = globalRequstID

	outputFilename := fmt.Sprintf("deepin-feedback-results-%s-%s-%d.tar.gz", category, time.Now().Format("2006-01-02"), time.Now().UnixNano()/1e9)
	outputFilepath := filepath.Join(os.TempDir(), outputFilename)
	logger.Info("generate report begin:", outputFilepath)
	fd.addWorkingRequest(requstID)

	go func() {
		_, _, err = utils.ExecAndWait(600, deepinFeedbackCliExe, "--output", outputFilepath, category)
		if err != nil {
			logger.Error(err)
		}

		// found the result file(s)
		files := make([]string, 0)
		fileInfos, err := ioutil.ReadDir(os.TempDir())
		if err != nil {
			logger.Error(err)
		} else {
			for _, f := range fileInfos {
				if !f.IsDir() && strings.HasPrefix(f.Name(), outputFilename) {
					files = append(files, filepath.Join(os.TempDir(), f.Name()))
				}
			}
		}

		dbus.Emit(fd, "GenerateReportFinished", requstID, files)
		logger.Info("generate report end:", outputFilepath)
		fd.removeWorkingRequest(requstID)
	}()
	return
}
