import atexit

from logger_files.mylogger import setup_logger

if __name__ == "__main__":

    root, listener = setup_logger()
    # The log output will display the thread which generated
    # the event (the main thread) rather than the internal
    # thread which monitors the internal queue. This is what
    # you want to happen.
    root.debug("debug message", extra={"x": "hello"})
    root.info("info message")
    root.warning("warning message")
    root.error("error message")
    root.critical("critical message")
    try:
        1 / 0
    except ZeroDivisionError:
        root.exception("exception message")
    atexit.register(listener.stop)
