import time
import sys


def type_out_text(text, delay=0.1):
    for char in text:
        sys.stdout.write(char)
        sys.stdout.flush()
        time.sleep(delay)
        if char == "\n":
            time.sleep(delay * 10)
        delay = delay * 0.995


if __name__ == "__main__":
    if not sys.stdin.isatty():
        text = sys.stdin.read()
        type_out_text(text)
    else:
        print("No piped input detected. Pipe some text into this script.")
