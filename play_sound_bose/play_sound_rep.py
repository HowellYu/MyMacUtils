import simpleaudio as sa
import time
import subprocess
import datetime
import sys

now = str(datetime.datetime.now())
date = now[:10]
log = open("logs/log-{}.log".format(date), "a")
sys.stdout = log
print('\n==================== {} log ===================='.format(now))

def play_music():
    filename = 'demo_raw_short.wav'
    print('Playing music', filename)
    wave_obj = sa.WaveObject.from_wave_file(filename)
    play_obj = wave_obj.play()
    play_obj.wait_done()  # Wait until sound has finished playing
    print('Finished...')

display = '6CM9100T78'
# test if connect to monitor
# play every 19 min

while(True):
    monitor_info = subprocess.run(['system_profiler', 'SPDisplaysDataType'], stdout=subprocess.PIPE)
    if display in str(monitor_info.stdout):
        print('Display is on!')
        play_music()
        time.sleep(5*60) # sleep for 19 mins
    else:
        print('Display is NOT on!')
        time.sleep(60)
