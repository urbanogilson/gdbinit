set auto-load safe-path /

set print pretty on
set pagination off

handle SIG34 nostop

# TUI aliases
define bt
  backtrace
  refresh
end

define c
  continue
  refresh
end

define n
  next
  refresh
end

define r
  run
  refresh
end

define u
  until
  refresh
end

define s
  step
  refresh
end

# Breakpoint aliases
define bpl
    info breakpoints
end
document bpl
List all breakpoints.
end

define bp
    if $argc != 1
        help bp
    else
        break $arg0
    end
end
document bp
Set breakpoint.
Usage: bp LOCATION
LOCATION may be a line number, function name, or "*" and an address.

To break on a symbol you must enclose symbol name inside "".
Example:
bp "[NSControl stringValue]"
Or else you can use directly the break command (break [NSControl stringValue])
end

define bpc 
    if $argc != 1
        help bpc
    else
        clear $arg0
    end
end
document bpc
Clear breakpoint.
Usage: bpc LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end

define bpe
    if $argc != 1
        help bpe
    else
        enable $arg0
    end
end
document bpe
Enable breakpoint with number NUM.
Usage: bpe NUM
end

define bpd
    if $argc != 1
        help bpd
    else
        disable $arg0
    end
end
document bpd
Disable breakpoint with number NUM.
Usage: bpd NUM
end

define bpt
    if $argc != 1
        help bpt
    else
        tbreak $arg0
    end
end
document bpt
Set a temporary breakpoint.
Will be deleted when hit!
Usage: bpt LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end

define bpm
    if $argc != 1
        help bpm
    else
        awatch $arg0
    end
end
document bpm
Set a read/write breakpoint on EXPRESSION, e.g. *address.
Usage: bpm EXPRESSION
end


define bhb
    if $argc != 1
        help bhb
    else
        hb $arg0
    end
end
document bhb
Set hardware assisted breakpoint.
Usage: bhb LOCATION
LOCATION may be a line number, function name, or "*" and an address.
end

# Process information
define argv
    show args
end
document argv
Print program arguments.
end

define stack
    if $argc == 0
        info stack
    end
    if $argc == 1
        info stack $arg0
    end
    if $argc > 1
        help stack
    end
end
document stack
Print backtrace of the call stack, or innermost COUNT frames.
Usage: stack <COUNT>
end

define frame
    info frame
    info args
    info locals
end
document frame
Print stack frame.
end

define var
    if $argc == 0
        info variables
    end
    if $argc == 1
        info variables $arg0
    end
    if $argc > 1
        help var
    end
end
document var
Print all global and static variable names (symbols), or those matching REGEXP.
Usage: var <REGEXP>
end

define lib
    info sharedlibrary
end
document lib
Print shared libraries linked to target.
end

define sig
    if $argc == 0
        info signals
    end
    if $argc == 1
        info signals $arg0
    end
    if $argc > 1
        help sig
    end
end
document sig
Print what debugger does when program gets various signals.
Specify a SIGNAL as argument to print info on that signal only.
Usage: sig <SIGNAL>
end

define threads
    info threads
end
document threads
Print threads in target.
end

define cls
    shell clear
end
document cls
Clear screen.
end

# Python commands
python
import gdb

def ntohl(value):
 """
 Converts a 32-bit integer from network byte order to host byte order.

 Args:
   value: The 32-bit integer to convert.

 Returns:
   The integer in host byte order.
 """
 return ((value >> 24) & 0xff) | \
        ((value >> 8) & 0xff00) | \
        ((value << 8) & 0xff0000) | \
        ((value << 24) & 0xff000000)

def ntohs(value):
 """
 Converts a 16-bit integer from network byte order to host byte order.

 Args:
   value: The 16-bit integer to convert.

 Returns:
   The integer in host byte order.
 """
 return ((value >> 8) & 0xff) | ((value << 8) & 0xff00)

# Define GDB commands
class NtohlCommand(gdb.Command):
 """Converts a 32-bit integer from network byte order to host byte order.

 Usage: ntohl <value> | <address>
 """

 def __init__(self):
   super().__init__("ntohl", gdb.COMMAND_USER)

 def invoke(self, arg, from_tty):
   try:
     # Try to parse as an integer
    value = int(arg, 0)  # Base 0 for automatic detection of hex, octal, etc.
    result = ntohl(value)
    print(
        f"ntohl: (0x{value:08x}) {value}\n"
        f"       (0x{result:08x}) {result}"
    )
   except ValueError:
     # If parsing as integer fails, try as an address
     try:
       value = int(gdb.parse_and_eval(arg))
       result = ntohl(value)
       print(
            f"ntohl: (0x{value:08x}) {value}\n"
            f"       (0x{result:08x}) {result}"
       )
     except Exception as e:
       print(f"Error: {e}")

class NtohsCommand(gdb.Command):
 """Converts a 16-bit integer from network byte order to host byte order.

 Usage: ntohs <value> | <address>
 """

 def __init__(self):
   super().__init__("ntohs", gdb.COMMAND_USER)

 def invoke(self, arg, from_tty):
    try:
        # Try to parse as an integer
        value = int(arg, 0)  # Base 0 for automatic detection of hex, octal, etc.
        result = ntohs(value)
        print(
            f"ntohs: (0x{value:04x}) {value}\n"
            f"       (0x{result:04x}) {result}"
        )
    except ValueError:
        # If parsing as integer fails, try as an address
        try:
            value = int(gdb.parse_and_eval(arg))
            result = ntohs(value)
            print(
                f"ntohs: (0x{value:04x}) {value}\n"
                f"       (0x{result:04x}) {result}"
            )
        except Exception as e:
            print(f"Error: {e}")

# Register the commands
NtohlCommand()
NtohsCommand()
end

alias valgrind = target remote | /libexec/valgrind/../../bin/vgdb
