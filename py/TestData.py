import struct
import time
import datetime
import json
import os
import socket

targetDir = 'TestData'
target_host='127.0.0.1'
target_port=3800
# Create a UDP socket
udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Message to send (convert to bytes)
message = b"TESTDONE"

PATH = os.getcwd()
indx = PATH.find('cRho')
PATH = PATH[:indx+4]

DATANUM = 660
NTx = 20
def SaveFileTest(FileNameBase):
    for idx in range(1,NTx+1):
        time.sleep(1)
        save_filename = os.path.join(PATH, targetDir, FileNameBase +f"-{idx:03}"+ ".dat")
        output_file = open(save_filename, "wb")
        print(save_filename+" Opend")
        with output_file as file:
            for j in [1,0,-1,0,-1,0,1,0]:    
                for i in range(DATANUM):
                    # print(j,*([0x3FFFFF, 0x7FFFF]*10), 0xFFF, 0xFF)
                    data = struct.pack("<23i",j,*([0x3FFFFF, 0x7FFFF]*10), 0xFFF, 0xFF)
                    output_file.write(data)    
                    time.sleep(0.001)
        print(save_filename+" SAVED")
        try:
            # Send the message to the target
            udp_socket.sendto(message, (target_host, target_port))
            print(f"Message sent to {target_host}:{target_port}: {message.decode('utf-8')}")
        except Exception as e:
            print(f"Error sending message: {str(e)}")
        finally:
            # Close the socket
            udp_socket.close()

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
        with open(os.path.join(PATH,"JSON","DCworkControl.json"), 'r') as f:
            job = json.load(f)
            job["FileNameBase"] = FileNameBase
            job["DoElectrodeTest"] = True
            #print(job)
    except FileNotFoundError as e:
            print("../JSON/DCworkControl.json not found")

    with open(os.path.join(PATH, targetDir,FileNameBase + ".json"), "w") as outfile:
        json.dump(job, outfile, indent=4)

if __name__ == '__main__':
    print("START")

    current_time = datetime.datetime.now()
    formatted_time = current_time.strftime("DC%Y-%m-%d-%H-%M")
    SaveJason(formatted_time)
    SaveFileTest(formatted_time)
    print("END")
