#! /usr/bin/python 
import PySimpleGUI as sg
import time
import sys
import subprocess as sb

def tcpdump(cmd,timeout=None):
        """ run shell command

        @param cmd: command to execute
        @param timeout: timeout for command execution

        @return: (return code from command, command output)
        """
        p = sb.Popen(cmd, shell=True, stdout=sb.PIPE, stderr=sb.STDOUT)
        output = ''
        for line in p.stdout:
                line = line.decode(errors='replace' if (sys.version_info) < (3, 5) else 'backslashreplace').rstrip()
                print(line)
                output += line


        retval = p.wait(timeout)
        #log.debug('retval=%d' % retval)

        #return (retval, output)

layout = [
        [sg.Text('bash wont let me show realtime output.')],
        [sg.Text('Enter number of second to capture tcp packets'),sg.InputText()],
        [sg.Checkbox('no dns lookup', change_submits = True, enable_events=True, default='0',key='dns'),
        sg.Checkbox('no promisicus mode', change_submits = True, enable_events=True, default='0', key='pmode'),
        sg.Checkbox('no port convertion', change_submits = True, enable_events=True, default='0', key='port')],
        [sg.Button('DUMP THE TCP')],
        [sg.Output(size=(110, 20))]
        ]

window = sg.Window('realtime output').Layout(layout)

while True:
    event, values= window.Read()
    if event in (None, 'Exit'):
        break
    if event == 'DUMP THE TCP':
        cmd = 'timeout {} tcpdump'.format(values[0])
        if values['dns']==True:
            cmd = cmd + " " + '-n'
        if values['pmode']==True:
            cmd = cmd + " " + '-p'
        if values['port']==True:
            cmd = cmd + " " + '-nn'
        tcpdump(cmd)
