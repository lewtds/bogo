# -*- coding: utf-8 -*-

from dogtail.procedural import *
from dogtail import tree
from subprocess import call, Popen
import os
import signal
import time
import unittest
from gi.repository import Gtk, Gdk
import SimpleHTTPServer
import SocketServer
import threading



keysequence = open(os.path.join(os.path.dirname(__file__), 'keysequence')).read().strip()
expected = open(os.path.join(os.path.dirname(__file__), 'expected')).read().strip()
server = None


def hasCommand(cmd):
    return call(['which', cmd]) == 0


def setUpModule():
    global server
    server = Popen('build/server')


def tearDownModule():
    server.kill()


class BogoTestCase(unittest.TestCase):
    def setUp(self):
        self.pid = run(self.command, appName=self.appName)
        focus.app(self.appName)

    def tearDown(self):
        os.kill(self.pid, signal.SIGTERM)

    def typeIn(self):
        # 80ms between each event -> ~75WPM
        call(['xdotool', 'type', '--delay', '80', keysequence])
        time.sleep(1)


@unittest.skipIf(not hasCommand('terminator'), "terminator not available")
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


@unittest.skipIf(not hasCommand('geany'), "geany not available")
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


@unittest.skipIf(not hasCommand('libreoffice'), 'libreoffice not available')
class TestLibreOfficeWriter(BogoTestCase):
    command = "make run CMD=tests/run-lowriter.sh GTK=2"
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
        time.sleep(0.5)

        self.assertEqual(focus.widget.text, expected)


@unittest.skipIf(not hasCommand('gvim'), 'gvim not available')
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


@unittest.skipIf(not hasCommand('inkscape'), 'inkscape not available')
class TestInkscape(BogoTestCase):
    command = 'make run GTK=2 CMD=inkscape'
    appName = 'inkscape'

    def testTypeInTextTool(self):
        # zoom in a bit
        call(['xdotool', 'key', '1'])

        # Create a text box
        call('xdotool search --onlyvisible --class Inkscape windowraise mousemove  --window %1 100 100 key F8 mousedown 1 mousemove_relative 200 200 mouseup 1', shell=True)

        self.typeIn()

        call(['xdotool', 'key', 'control+a'])
        time.sleep(1)
        call(['xdotool', 'key', 'control+c'])
        time.sleep(1)

        clipboard_text = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD).wait_for_text()
        self.assertEqual(clipboard_text, expected)


@unittest.skipIf(not hasCommand('firefox'), 'firefox not available')
class TestFirefox(BogoTestCase):
    command = 'make run GTK=2 CMD=firefox'
    appName = 'Firefox'
    httpd = None

    @classmethod
    def setUpClass(cls):
        def serve():
            PORT = 8000
            Handler = SimpleHTTPServer.SimpleHTTPRequestHandler
            cls.httpd = SocketServer.TCPServer(("", PORT), Handler)
            cls.httpd.serve_forever()

        threading.Thread(target=serve).start()

        cls.pid = run(cls.command, appName=cls.appName)
        cls.app = tree.root.application('Firefox')
        time.sleep(2)

    @classmethod
    def tearDownClass(cls):
        cls.httpd.shutdown()
        os.kill(cls.pid, signal.SIGTERM)

    def setUp(self):
        pass

    def tearDown(self):
        pass

    def goToAddress(self, addr):
        address_bar = self.app.child(roleName='entry',
                                     name='Search or enter address')
        address_bar.text = addr
        address_bar.keyCombo('Return')
        time.sleep(5)

    def testTypeInVanillaTextArea(self):
        self.goToAddress('http://localhost:8000/tests/text-area.html')
        page = self.app.child(roleName='document frame',
                              name='Bogo Text Area Test')
        entry = page.child(name='test area', roleName='entry')
        entry.click()

        self.typeIn()

        self.assertEqual(entry.text, expected)

    @unittest.expectedFailure
    def testTypeInFacebookComment(self):
        self.goToAddress('http://localhost:8000/tests/facebook-comment.html')
        page = self.app.child(roleName='document frame',
                              name='Bogo Facebook Comments Test')

        fb = page.child(roleName='document frame',
                        name='Facebook Social Plugin')

        commentDiv = fb[0][0][0][0][1][1][0][0]
        commentDiv.click()

        self.typeIn()

        entry = page.child(roleName='combo box')[0][0]
        self.assertEqual(entry.text, expected)


if __name__ == '__main__':
    unittest.main()
