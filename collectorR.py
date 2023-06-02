import cv2

from rtsp import RTSP

from pathlib import Path
from datetime import datetime, timedelta

class CamOnly:
    def __init__(self):
        self.ip_addr = "http://0"

        self.win_w, self.win_h = (1280, 720)
        self.fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        self.fps = 30.0

        self.vid_dir = Path('Videos')

        self.vid_dir.mkdir(parents=True, exist_ok=True)

        self.exit_pro = False

        self.max_vid_time_seconds = 60

        self.win_title = 'Collector'
        cv2.namedWindow(self.win_title, cv2.WINDOW_NORMAL)

        self.run()


    def draw_time(self, frame):
        time_str = str(datetime.now())

        img_height, img_width = frame.shape[:2]
        size = min([img_height, img_width]) * 0.001
        text_thickness = int(min([img_height, img_width]) * 0.001)

        # Draw bounding boxes and labels of detections
        color = [0, 0, 0]

        x1, y1 = 10, self.win_h - 30

        (tw, th), _ = cv2.getTextSize(text=time_str, fontFace=cv2.FONT_HERSHEY_SIMPLEX,
                                    fontScale=size, thickness=text_thickness)
        th_b = int(th * 1.3)

        x2, y2_box, y2_text = x1 + tw, y1 + th_b, y1 + th + 2

        cv2.rectangle(frame, (x1, y1),
                    (x2, y2_box), color, -1)
        
        cv2.putText(frame, time_str, (x1, y2_text),
                    cv2.FONT_HERSHEY_SIMPLEX, size, (255, 255, 255), text_thickness, cv2.LINE_AA)

    def create_video(self):

        vid_name = self.vid_dir / f'Collector{len(list(self.vid_dir.iterdir()))}.mp4'

        print('Create new video:', vid_name)

        self.vid_w = cv2.VideoWriter(str(vid_name), self.fourcc, self.fps, (self.win_w, self.win_h))

    def update_time_counter(self):
        self.counter_vid_time = datetime.now() + timedelta(seconds=self.max_vid_time_seconds)

    def run(self) -> None:
        self.camera_auto_reconnect = True

        self.rtsp = RTSP(self.ip_addr, self.camera_auto_reconnect, None, img_size=(self.win_w, self.win_h))

        self.update_time_counter()

        while True:
            self.create_video()

            while True:
                frame = self.rtsp.read()
                if not self.rtsp.isOpened():
                    break

                self.draw_time(frame)

                cv2.imshow(self.win_title, frame)

                self.vid_w.write(frame)

                key = cv2.waitKey(1)

                if key == ord('q'):
                    self.exit_pro = True
                    
                    break

                elif key == 27 or key == ord('w'):
                    print('Press w.')
                    break

                if datetime.now() >= self.counter_vid_time:
                    self.update_time_counter()
                    break

            self.vid_w.release()

            if self.exit_pro:
                break

        cv2.destroyAllWindows()
        self.rtsp.exit()
        self.rtsp.join()
        print('Terminated collector.')

if __name__ == '__main__':
    app = CamOnly()

