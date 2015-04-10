# -*- coding: utf-8 -*-

from dogtail.procedural import *
from subprocess import call, Popen
import os
import signal
import time
import unittest


keysequence = open(os.path.join(os.path.dirname(__file__), 'keysequence')).read().strip()
expected = open(os.path.join(os.path.dirname(__file__), 'expected')).read().strip()
server = None


def setUpModule():
    global server
    server = Popen('build/server')


def tearDownModule():
    server.kill()


class BogoTestCase(unittest.TestCase):
    def setUp(self):
        self.pid = run(self.command, appName=self.appName)
        focus.application(name=self.appName)

    def tearDown(self):
        os.kill(self.pid, signal.SIGTERM)

    def typeIn(self):
        call(['xdotool', 'type', keysequence])
        time.sleep(1)


class TestTerminator(BogoTestCase):
    command = 'make run GTK=2 CMD=terminator'
    appName = 'terminator'

    def testTypeInMainTerminal(self):
        focus.widget(name='Terminal')
        separator = 'LOL___CAT'

        call(['xdotool', 'type', separator])
        self.typeIn()

        widgetText = focus.widget.text.strip().split(separator)[-1]
        self.assertEqual(widgetText, expected)


class TestGeany(BogoTestCase):
    command = 'make run GTK=2 CMD=geany'
    appName = 'geany'

    def setUp(self):
        super(TestGeany, self).setUp()
        self.destFile = '/tmp/abcabc.txt'
        call(['rm', '-rf', self.destFile])

    def testTypeInNewDocument(self):
        call(['xdotool', 'key', 'control+n'])

        self.typeIn()

        call(['xdotool', 'key', 'control+s'])
        time.sleep(1)
        call(['xdotool', 'type', self.destFile])
        time.sleep(1)
        call(['xdotool', 'key', 'Return'])
        time.sleep(1)

        with open(self.destFile) as f:
            self.assertEqual(f.read().strip(), expected)


class TestLibreOfficeWriter(BogoTestCase):
    command = 'make run GTK=2 CMD="lowriter --nologo --norestore"'
    appName = 'soffice'

    def tearDown(self):
        # somehow soffice forks itself to a new process and we don't
        # have its PID
        call(['xdotool', 'key', 'control+q'])
        time.sleep(1)
        call(['xdotool', 'key', 'Left'])
        call(['xdotool', 'key', 'Left'])
        call(['xdotool', 'key', 'Return'])

    def testTypeInNewDocumentFirstParagraph(self):
        focus.widget(roleName='paragraph')

        self.typeIn()

        self.assertEqual(focus.widget.text, expected)


class TestGVim(BogoTestCase):
    command = 'make run GTK=2 CMD=gvim'
    appName = 'gvim'

    def setUp(self):
        super(TestGVim, self).setUp()
        self.destFile = '/tmp/abcabc.txt'
        call(['rm', '-rf', self.destFile])

    def tearDown(self):
        pass

    def testTypeInNewDocument(self):
        # Insert mode
        call(['xdotool', 'key', 'i'])

        self.typeIn()

        call(['xdotool', 'key', 'Escape'])
        # FIXME: turn off TELEX before saving to avoid double pressing w
        call(['xdotool', 'type', ':wwq ' + self.destFile])
        call(['xdotool', 'key', 'Return'])
        time.sleep(1)

        with open(self.destFile) as f:
            self.assertEqual(f.read().strip(), expected)

if __name__ == '__main__':
    unittest.main()
