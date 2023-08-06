
# HTML FOR COVER PAGE
$h = @"

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
<style>
 @media only screen and (max-width: 768px) {
  /* For mobile phones: */
  [class*="col-"] {
    width: 100%;
  }
}
 @-ms-viewport {
  width: device-width;
}
html {
 height:100%;
 border-bottom: 25px solid #000000;
}
body {
  background-color: black;
  height: 100vh;
  margin: 0;
  overflow: hidden;
  padding: 2rem;
  color: white;
  font: 1.3rem Inconsolata, monospace;
  font-size: 1vw;
  text-shadow: 0 0 5px #C8C8C8;
  &::after {
    content: "";
    position: absolute;
    top: 0;
    left: 0;
    max-width:100%;
    width: 100vw;
    height: 100vh;
    pointer-events: none;
  }
}
::selection {
  background: #0080FF;
  text-shadow: none;
}
pre {
  margin: 0;
}

:root {
    --color-bg: #252a33;
    --color-text: #eee;
    --color-text-subtle: #a2a2a2;
}

body {
    max-width: 100%;
}

[data-termynal] {
    color: var(--color-text);
    font-size: 1vw;
    border-radius: 4px;
    position: relative;
}

[data-termynal]:before {
    content: '';
    position: absolute;
    top: 15px;
    left: 15px;
    display: inline-block;
    width: 15px;
    height: 15px;
    border-radius: 50%;
}

[data-termynal]:after {
    position: absolute;
    color: var(--color-text-subtle);
    left: 0;
    text-align: center;
}

[data-ty] {
    display: block;
    line-height: 1.2em;
}



[data-ty]:before {
    content: '';
    display: inline-block;
    vertical-align: middle;
}

[data-ty="input"]:before,
[data-ty-prompt]:before {
    margin-right: 0.50em;
    color: var(--color-text-subtle);
}

[data-ty="input"]:before {
    content: 'root@localhost#';
}

[data-ty="login"]:before {
    margin-right: 0.50em;
    color: var(--color-text);
}

[data-ty="login"]:before {
    content: 'localhost login: ';
}

[data-ty="password"]:before {
    margin-right: 0.50em;
    color: var(--color-text);
}

[data-ty="password"]:before {
    content: 'root password: ';
}

[data-ty][data-ty-prompt]:before {
    content: attr(data-ty-prompt);
}

[data-ty-cursor]:after {
    content: attr(data-ty-cursor);
    margin-left: 0.5em;
    -webkit-animation: blink 1s infinite;
            animation: blink 1s infinite;
}


/* Cursor animation */

@-webkit-keyframes blink {
    50% {
        opacity: 0;
    }
}

@keyframes blink {
    50% {
        opacity: 0;
    }
}
</style>
</head>
<body>
<div id="termynal" data-termynal data-ty-delay="0">
<span data-ty="login" data-ty-delay="20" data-ty-typeDelay="262">root</span>
<span data-ty="password" data-ty-delay="3000" data-ty-cursor="▋">  </span>
<span data-ty data-ty-delay="0"></span>
<span data-ty data-ty-delay="0"></span>
<span data-ty><pre>Welcome to Ubuntu 18.04.4 LTS (GNU/Linux 4.15.0-108-generic x86_64)


  System load:  0.0                Processes:             19
  Usage of /:   3.4% of 8.49TB     Users logged in:       0
  Memory usage: 9%                 IP address for eth0:   192.168.201.11
  Swap usage:   0%


1 package can be updated.
0 updates are security updates.</pre></span>
<span data-ty data-ty-delay="0"></span>
<span data-ty data-ty-delay="4050" data-ty-cursor="▋">Connecting.. Please Wait...</span>
<span data-ty data-ty-delay="0"></span>
<span data-ty data-ty-delay="0"></span>
<span data-ty="input" data-ty-delay="0">bash -c ./pornhub.com</span>
<span data-ty data-ty-delay="1250">bash: ./pornhub.com: No such file or directory</span>
<span data-ty="input" data-ty-delay="100" data-ty-cursor="▋" data-ty-typeDelay="100">Suck your Grandma's Toenail</span>
<span data-ty data-ty-delay="1200">bash: Suck your Grandma's Toenail: No such file or directory</span>
<span data-ty="input" data-ty-delay="1000" data-ty-cursor="▋" data-ty-typeDelay="100">start</span>
<span data-ty data-ty-delay="2000">Loading... Please Wait...</span>
<span data-ty data-ty-delay="2000">Failed!</span>
<span data-ty="input" data-ty-delay="400">?help</span>

<span data-ty data-ty-delay="0">ERROR: We are currently under maintenance.</span>
<span data-ty data-ty-delay="0">            Try coming back later!</span>
<span data-ty data-ty-delay="0"></span>
<span data-ty data-ty-delay="0">                 -beigeworm</span>
<span data-ty></span>
<span data-ty="input" data-ty-cursor="▋" data-ty-typeDelay="250">exit</span>
<span data-ty data-ty-delay="1650">disconnected.</span>
<script>
'use strict';
class Termynal {
    constructor(container = '#termynal', options = {}) {
        this.container = (typeof container === 'string') ? document.querySelector(container) : container;
        this.pfx = ``data-`${options.prefix || 'ty'}``;
        this.startDelay = options.startDelay
            || parseFloat(this.container.getAttribute(```${this.pfx}-startDelay``)) || 600;
        this.typeDelay = options.typeDelay
            || parseFloat(this.container.getAttribute(```${this.pfx}-typeDelay``)) || 90;
        this.lineDelay = options.lineDelay
            || parseFloat(this.container.getAttribute(```${this.pfx}-lineDelay``)) || 1500;
        this.progressLength = options.progressLength
            || parseFloat(this.container.getAttribute(```${this.pfx}-progressLength``)) || 40;
        this.progressChar = options.progressChar
            || this.container.getAttribute(```${this.pfx}-progressChar``) || '█';
		this.progressPercent = options.progressPercent
            || parseFloat(this.container.getAttribute(```${this.pfx}-progressPercent``)) || 100;
        this.cursor = options.cursor
            || this.container.getAttribute(```${this.pfx}-cursor``) || '▋';
        this.lineData = this.lineDataToElements(options.lineData || []);
        if (!options.noInit) this.init()
    }

    init() {
        this.lines = [...this.container.querySelectorAll(``[`${this.pfx}]``)].concat(this.lineData);

        const containerStyle = getComputedStyle(this.container);
        this.container.style.width = containerStyle.width !== '0px' ? 
            containerStyle.width : undefined;
        this.container.style.minHeight = containerStyle.height !== '0px' ? 
            containerStyle.height : undefined;

        this.container.setAttribute('data-termynal', '');
        this.container.innerHTML = '';
        this.start();
    }

    async start() {
        await this._wait(this.startDelay);

        for (let line of this.lines) {
            const type = line.getAttribute(this.pfx);
            const delay = line.getAttribute(```${this.pfx}-delay``) || this.lineDelay;

            if (type == 'input') {
                line.setAttribute(```${this.pfx}-cursor``, this.cursor);
                await this.type(line);
                await this._wait(delay);
            }

            if (type == 'login') {
                line.setAttribute(```${this.pfx}-cursor``, this.cursor);
                await this.type(line);
                await this._wait(delay);
            }

            if (type == 'password') {
                line.setAttribute(```${this.pfx}-cursor``, this.cursor);
                await this.type(line);
                await this._wait(delay);
            }

            else if (type == 'progress') {
                await this.progress(line);
                await this._wait(delay);
            }

            else {
                this.container.appendChild(line);
                await this._wait(delay);
            }
            
            line.removeAttribute(```${this.pfx}-cursor``);
        }
    }

    async type(line) {
        const chars = [...line.textContent];
        const delay = line.getAttribute(```${this.pfx}-typeDelay``) || this.typeDelay;
        line.textContent = '';
        this.container.appendChild(line);

        for (let char of chars) {
            await this._wait(delay);
            line.textContent += char;
        }
    }

    async progress(line) {
        const progressLength = line.getAttribute(```${this.pfx}-progressLength``)
            || this.progressLength;
        const progressChar = line.getAttribute(```${this.pfx}-progressChar``)
            || this.progressChar;
        const chars = progressChar.repeat(progressLength);
		const progressPercent = line.getAttribute(```${this.pfx}-progressPercent``)
			|| this.progressPercent;
        line.textContent = '';
        this.container.appendChild(line);

        for (let i = 1; i < chars.length + 1; i++) {
            await this._wait(this.typeDelay);
            const percent = Math.round(i / chars.length * 100);
            line.textContent = ```${chars.slice(0, i)} `${percent}%``;
			if (percent>progressPercent) {
				break;
			}
        }
    }

    _wait(time) {
        return new Promise(resolve => setTimeout(resolve, time));
    }

    lineDataToElements(lineData) {
        return lineData.map(line => {
            let div = document.createElement('div');
            div.innerHTML = ``<span `${this._attributes(line)}>`${line.value || ''}</span>``;

            return div.firstElementChild;
        });
    }

    _attributes(line) {
        let attrs = '';
        for (let prop in line) {
            attrs += this.pfx;

            if (prop === 'type') {
                attrs += ``="`${line[prop]}" ``
            } else if (prop !== 'value') {
                attrs += ``-`${prop}="`${line[prop]}" ``
            }
        }

        return attrs;
    }
}

if (document.currentScript.hasAttribute('data-termynal-container')) {
    const containers = document.currentScript.getAttribute('data-termynal-container');
    containers.split('|')
        .forEach(container => new Termynal(container))
}
var termynal = new Termynal('#termynal', { startDelay: 600 })
</script>
</body>
</html>


"@

# SAVE HTML
$p = "$env:temp/bash.htm"
$h | Out-File -Encoding UTF8 -FilePath $p
$a = "file://$a"

# KILL ANY BROWSERS (interfere with "Maximazed" argument)
Start-Process -FilePath "taskkill" -ArgumentList "/F", "/IM", "chrome.exe", "/IM", "msedge.exe" -NoNewWindow -Wait
Sleep -Milliseconds 100

# START EDGE IN FULLSCREEN
$edgeProcess = Start-Process -FilePath "msedge.exe" -ArgumentList "--kiosk $env:temp/bash.htm -WindowStyle Maximized"

Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll")]
        public static extern IntPtr SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
        public static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
        public static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
        public const uint SWP_NOMOVE = 0x2;
        public const uint SWP_NOSIZE = 0x1;
        public const uint SWP_SHOWWINDOW = 0x40;
    }
"@

# SET EDGE AS TOP WINDOW AND START SCREENSAVER
$null = [Win32]::SetWindowPos($edgeProcess.MainWindowHandle, [Win32]::HWND_TOPMOST, 0, 0, 0, 0, [Win32]::SWP_NOMOVE -bor [Win32]::SWP_NOSIZE -bor [Win32]::SWP_SHOWWINDOW)
Sleep -Milliseconds 250
$null = [Win32]::SetWindowPos($edgeProcess.MainWindowHandle, [Win32]::HWND_TOPMOST, 0, 0, 0, 0, [Win32]::SWP_NOMOVE -bor [Win32]::SWP_NOSIZE -bor [Win32]::SWP_SHOWWINDOW)
Sleep -Milliseconds 250