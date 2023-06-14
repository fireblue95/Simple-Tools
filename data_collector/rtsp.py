import cv2
import logging
import numpy as np

from time import sleep
from threading import Thread

class RTSP:
    def __init__(self, source: str = None,
                 auto_reconnect: bool = False,
                 logger: logging.Logger = None,
                 timeout: int = 5,
                 verbose: bool = True,
                 img_size: tuple = None):
        """
            img_size = (w, h)
        """

        assert source is not None, "source is None"
        self._source = source

        self._auto_reconnect = auto_reconnect

        self._LOGGER = logger

        self._timeout = timeout

        self._verbose = verbose

        self._img_size = img_size

        self.__init_variables__()

        self.__connect_camera__()

        self._th = Thread(target=self.run, args=(), daemon=True)
        self._th.start()
        
    def __init_variables__(self) -> None:
        if self.__display_msg__():
            self._LOGGER.logger_sys.info(f"Camera auto reconnect: {self._auto_reconnect}")

        self._stream = None

        self._running = False

        self._queue = None

        self._exit = False
    
    def __update__(self, frame: np.ndarray) -> None:
        if self._img_size is not None and (frame.shape[0] != self._img_size[1] or frame.shape[1] != self._img_size[0]):
            self._queue = cv2.resize(frame, self._img_size)
        else:
            self._queue = frame

    def __connect_camera__(self) -> None:

        if self._auto_reconnect:
            while True:
                self._stream = cv2.VideoCapture(self._source)

                success, frame = self._stream.read()
                if success:
                    self._running = True
                    self.__update__(frame)

                    if self.__display_msg__():
                        self._LOGGER.logger_sys.info('攝影機已連接(Camera connected)')
                    break
                else:
                    self._running = False
                    self._queue = None

                    if isinstance(self._stream, cv2.VideoCapture):
                        self._stream.release()
                        self._stream = None

                    if self.__display_msg__():
                        self._LOGGER.logger_sys.warning(f"{self._timeout}秒後將嘗試重新連接至攝影機({self._source})")
                    sleep(self._timeout)

                if self._exit:
                    self._running = False
                    break

            return
        
        self._stream = cv2.VideoCapture(self._source)

        success, frame = self._stream.read()
        if success:
            self._running = True
            self.__update__(frame)

            if self.__display_msg__():
                self._LOGGER.logger_sys.info('攝影機已連接(Camera is connected)')
        else:
            self._running = False
            self._queue = None

            self._stream.release()
            self._stream = None

            if self.__display_msg__():
                self._LOGGER.logger_sys.error('攝影機連接失敗(Camera connection is failed)')

    def __run__(self) -> None:
        while self.isOpened():
            success, frame = self._stream.read()

            if not success or self._exit:
                self._running = False
                self._queue = None
                break
            
            self.__update__(frame)

        if isinstance(self._stream, cv2.VideoCapture):
            self._stream.release()
        self._stream = None
    
    def __display_msg__(self) -> bool:
        return self._verbose and (self._LOGGER is not None) and (self._LOGGER.logger_sys is not None)
    
    def read(self) -> np.ndarray:
        """
            return BGR Image
        """

        return self._queue

    def exit(self) -> None:
        self._exit = True
        self._running = False
        self._queue = None

    def run(self) -> None:
        if self._auto_reconnect:
            while True:
                if self._stream is None:
                    self.__connect_camera__()

                self.__run__()

                if self._exit:
                    break
        else:
            self.__run__()

        self.exit()

    def isOpened(self) -> bool:
        return self._stream is not None and self._stream.isOpened() and self._running

    def join(self) -> None:
        self._th.join()


if __name__ == "__main__":

    source = 'https://0'
    app = RTSP(source, img_size=(1280, 720))

    while app.isOpened():
        
        frame = app.read()

        if not app.isOpened():
            break
        
        cv2.imshow('Streaming', frame)

        if cv2.waitKey(1) == ord('q'):
            app.exit()
            break
    
    app.exit()
    print('Waiting for termination...')
    app.join()
    print('Closed.')
    
    
