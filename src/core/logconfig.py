import logging
from colorlog import ColoredFormatter
import rich
class Log:
    """
    Utility class for creating application and App loggers with
    consistent formatting. Provides both file and colorized
    console output using `logging` and `colorlog`.
    """
    file_formatter = logging.Formatter(
            "%(levelname)s:    %(asctime)s - %(name)s - %(message)s"
        )
    stream_formatter ="%(log_color)s%(levelname)s%(reset)s:    [%(asctime)s,\033[1;90m%(msecs)03d\033[0m] - {{\033[38;2;235;9;220m%(name)s\033[0m}} @""%(log_color)s%(message)s"
    stream_formatter = ColoredFormatter(
        stream_formatter,
        datefmt="%Y/%b/%d %H:%M:%S", #https://docs.python.org/3/library/datetime.html#strftime-and-strptime-format-codes
        log_colors={
            "DEBUG": "cyan",
            "INFO": "green",
            "WARNING": "yellow",
            "ERROR": "red",
            "CRITICAL": "bold_red",
        },
    )
    def __init__(self,log_name=__name__):
        """
        Initialize a logging wrapper.

        Parameters
        ----------
        log_name : str
            Name of the logger to create or configure.
        """
        self.log_name=log_name

    def app_logger(self):
        """
        Create and return an application logger configured with both
        file and colorized console handlers.

        Returns
        -------
        logging.Logger
            The configured logger instance.
        """
        logger = logging.getLogger(self.log_name)
        logger.setLevel(logging.DEBUG)

        file_handler = logging.FileHandler(filename='logs/app.log',
        encoding='utf-8',
        mode='w')
        file_handler.setLevel(logging.DEBUG)

        stream_handler = logging.StreamHandler()
        stream_handler.setLevel(logging.DEBUG)

        file_handler.setFormatter(Log.file_formatter)
        stream_handler.setFormatter(Log.stream_formatter)

        logger.addHandler(file_handler)
        logger.addHandler(stream_handler)

        return logger
if __name__=="__main__":
    logger=Log(__name__).app_logger()
    logger.debug("debug message")
    logger.info("info message")
    logger.warning("warning message")
    logger.error("error message")
    logger.critical("critical message")
    
    try:
        1/0
        pass
    except Exception:
        logger.exception("unknown error")
