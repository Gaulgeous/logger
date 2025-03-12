import atexit
import json
import logging.config
import logging.handlers
import pathlib
import queue
from logging.handlers import QueueHandler, QueueListener

from typing import Tuple


def setup_logger() -> Tuple[logging.Logger, QueueListener]:
    config_file = pathlib.Path("logging_configs/logging_config.json")
    with open(config_file) as f_in:
        config = json.load(f_in)

    logging.config.dictConfig(config)

    que: queue.Queue = queue.Queue(-1)  # no limit on size
    queue_handler = QueueHandler(que)
    # handler = logging.StreamHandler()
    listener = QueueListener(que)
    root = logging.getLogger(__name__)

    # formatter = logging.Formatter("[%(levelname)s|%(module)s|L%(lineno)d] %(asctime)s: %(message)s")
    # handler.setFormatter(formatter)
    root.addHandler(queue_handler)
    listener.start()

    return (root, listener)


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
