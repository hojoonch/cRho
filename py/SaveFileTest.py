import struct
import time
import datetime
import json
import os

PATH = "/home/pi/cRho/" # FOR LINUX
#PATH = ".\\DataDC\\" # FOR WINDOWS
DATANUM = 1320
NTx = 1
def SaveFileTest(FileNameBase):
    for idx in range(1,NTx+1):
        time.sleep(0.1)
        save_filename = os.path.join(PATH, "DataDC", FileNameBase +f"-{idx:03}"+ ".dat")
        output_file = open(save_filename, "wb")
        with output_file as file:
            for j in [1,0,-1,0,-1,0,1,0]:    
                for i in range(DATANUM):
                    # print(j,*([0x3FFFFF, 0x7FFFF]*10), 0xFFF, 0xFF)
                    data = struct.pack("<23i",j,*([0x3FFFFF, 0x7FFFF]*10), 0xFFF, 0xFF)
                    output_file.write(data)    
                    time.sleep(0.001)
        print(save_filename+" SAVED")

def SaveJason(FileNameBase):
    try:
        if not os.path.exists(PATH):
            os.makedirs(PATH)
    except OSError:
        print('Error: Creating directory. ' + PATH)
        return
    
    try:
        #print(PATH)
        #rint(os.path.join(PATH,"JSON/DCworkControl.json"))
        with open(os.path.join(PATH,"JSON/DCworkControl.json"), 'r') as f:
            job = json.load(f)
            job["FileNameBase"] = FileNameBase
            #print(job)
    except FileNotFoundError as e:
            print("../JSON/DCworkControl.json not found")

    with open(os.path.join(PATH, "DataDC",FileNameBase + ".json"), "w") as outfile:
        json.dump(job, outfile, indent=4)

if __name__ == '__main__':
    print("START")

    current_time = datetime.datetime.now()
    formatted_time = current_time.strftime("DC%Y-%m-%d-%H-%M")
    SaveJason(formatted_time)
    SaveFileTest(formatted_time)
    print("END")
