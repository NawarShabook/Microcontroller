import time, threading
from tkinter import *
from tkinter import messagebox
import serial
import sys
from datetime import datetime

StartTime=time.time()
class setInterval :
    def __init__(self,interval,action) :
        self.interval=interval
        self.action=action
        self.stopEvent=threading.Event()
        thread=threading.Thread(target=self.__setInterval)
        thread.start()

    def __setInterval(self) :
        nextTime=time.time()+self.interval
        while not self.stopEvent.wait(nextTime-time.time()) :
            nextTime+=self.interval
            self.action()

    def cancel(self) :
        self.stopEvent.set()


try:
    ser = serial.Serial('COM3', 9600, timeout=1, bytesize=8)
except:
    exit('no serial connection...')


adc_val = None
volt_level =None
volt_value = None

pwm = False
adc=False
root = Tk()
root.title("Control micro")
root.geometry("600x600")
root.configure(bg='white')
label = Label(root, text="Interface for micro control", font=("Helvetica", 16))
label.pack(pady=20)



def hex2bin(e):
    return '0b' + bin(int.from_bytes(e, byteorder=sys.byteorder, signed=False))[2:].zfill(8)

def binary2decimal(num=0):
    return int(num,2)

def fullResolution(twobyte=[]):
    high8bit = twobyte[0][2:]  
    low2bit = twobyte[1][2:]
    r16bit = f'{high8bit}{low2bit}'
    return r16bit

def exit1():
    inter.cancel()
    root.quit()
    exit()

def toggle_led():
    if ser.isOpen():
        ser.write(b'1')  # Send command to turn LED on
    if led_button["text"] == "Turn LED On":
        led_button["text"] = "Turn LED Off"
        led_button["bg"] = "red"
        led_label["image"] = led_on_image
    else:
        led_button["text"] = "Turn LED On"
        led_button["bg"] = "green"
        led_label["image"] = led_off_image

def toggle_adc():
    global adc
    if adc_state_btn["text"] == "ON ADC":
        adc = True
        adc_state_btn["text"] = "OFF ADC"
        adc_state_btn["bg"] = "red"
        adc_button.config(state=NORMAL)
    else:    
        adc_state_btn["text"] = "ON ADC"
        adc_state_btn["bg"] = "green"
        adc = False
        adc_button.config(state=DISABLED)

def adc_read():
    global adc_val, volt_level, volt_value  # list for store ADCH and ADCL after convert it
    l = []  # list for store ADCH and ADCL
    cmd = b'3'  # send command to start ADC and return the value
    if ser.isOpen() and ser.in_waiting==0:
        ser.write(cmd)
        while True:  # loop for read all data
            recv_data = ser.read()
            if recv_data == b'':  # if receve data is empty
                break
            else:
                # s+=hex2bin(recv_data)
                l.append(recv_data)  # add receve data to list
    l1 = [hex2bin(x) for x in l]  # convert Hexa data in list to Binary
    print(l1)
    adc_val=fullResolution(l1) #get 16bit
    volt_level=binary2decimal(adc_val) #convert to decimal
    volt_value= (5 * volt_level / 1023) #get volt value
    volt_value=round(volt_value,4) #round vlaue
    adc_label['text']=f'adc:{adc_val}\nvolt level:{volt_level}\nvolt value:{volt_value}V'

def save_file():
    global adc_val,volt_value,volt_level
    current_date = datetime.now().date()
    current_time = datetime.now().time().strftime("%H:%M")

    # open file in append mode ('a')
    if volt_level is None:
        messagebox.showerror("no values","there are no values to save it")
        return
    try:
        with open('adc-file.txt', 'a') as file:
            # Write the text to the file
            file.write(f'date:{current_date}, time:{current_time}\n')
            file.write(f'adc:{adc_val}\nvolt level:{volt_level}\nvolt value:{volt_value}V\n')
            adc_val=None
            volt_level=None
            volt_value=None

            adc_label['text']=''
            messagebox.showinfo("success", "saved successfully")

    except:
        messagebox.showerror("error save", "not save successfully...!")
def toggle_pwm():
    global pwm
    if pwm_btn["text"] == "ON PWM":
        pwm_btn["text"] = "OFF PWM"
        pwm_btn["bg"] = "red"
        pwm = True
        pwm_slider.config(state=NORMAL)
        pwm_label_state['text'] = ""
    else:
        pwm_btn["text"] = "ON PWM"
        pwm_btn["bg"] = "green"
        pwm_slider.set(0)
        pwm = False
        if ser.isOpen():
            ser.write(b'M')  # send the value to the serial port as bytes to


def on_slider_change(val):
    if (pwm):
        cmd = chr(int(val))  # convert scale number to int then get ascii char for this number
        cmd = bytes(cmd, 'utf-8')  # convert string ascii char to byte
        print(cmd)
        if b'0' <= cmd <= b'9':  # if slider val is between 0-9 dont send it, this range for another works
            return
        if ser.isOpen():
            ser.write(cmd)  # send the value to the serial port as bytes to
        print("Slider value:", val)
    else:
        pwm_slider.set(0)
        pwm_label_state['text'] = "pwm not enable...!"
        pwm_slider.config(state=DISABLED)


def check_exit():
    if adc is False and pwm is False:
        if ser.isOpen() and ser.in_waiting==0:
            ser.write(b'5')
            recv_data = ser.read()
            print(recv_data)
            recv_data = hex2bin(recv_data)
            print(recv_data)
            if recv_data == '0b00000101':
                inter.cancel()
                exit1()


ex_btn = Button(root, text="exit" ,bg='red', fg='white', font=("Helvetica", 12) ,command=exit1)
ex_btn.pack()

# Led section
led_frame = Frame(root, bg='white')
led_frame.pack(pady=20)
led_button = Button(led_frame, text="Turn LED On", font=("Helvetica", 14), bg='green', fg='white', command=toggle_led)
led_on_image = PhotoImage(file="images/led on1.png")
led_off_image = PhotoImage(file="images/led off1.png")
led_label = Label(led_frame, image=led_off_image, bg='white')
led_button.grid(row=0, column=0)
led_label.grid(row=0, column=5)

# ADC section
adc_frame = Frame(root, bg='white', bd=10, highlightbackground="orange",  highlightthickness=5)
adc_frame.pack(pady=20)
adc_state_btn = Button(adc_frame, text="ON ADC", bg='green', fg='white', command=toggle_adc)
adc_button = Button(adc_frame, text="ADC read", font=("Helvetica", 14), bg='orange', fg='white', state=DISABLED ,command=adc_read)
adc_image = PhotoImage(file="images/adc.png")
adc_label_image = Label(adc_frame, image=adc_image, bg='white')
adc_save_file = Button(adc_frame, text="save adc value in file", font=("Helvetica", 12), bg='blue', fg='white',
                       command=save_file)
adc_label=Label(adc_frame,font=("Helvetica", 10))

adc_state_btn.grid(row=0,column=1)
adc_label_image.grid(row=1, column=0)
adc_button.grid(row=1, column=1)
adc_label.grid(row=2, column=0)
adc_save_file.grid(row=2, column=1)

# PWM section
pwm_frame = Frame(root, bg='white', bd=10, highlightbackground="blue",  highlightthickness=5)
pwm_frame.pack(pady=20)

pwm_label = Label(pwm_frame, text="PWM slider")
pwm_btn = Button(pwm_frame, text="ON PWM", bg='green', fg='white', command=toggle_pwm)
pwm_slider = Scale(pwm_frame, from_=0, to=126, orient='horizontal', font=("Helvetica", 12), bg='green', fg='white',
                   command=on_slider_change)

pwm_image = PhotoImage(file="images/pwm11.png")
pwm_label_image = Label(pwm_frame, image=pwm_image, bg='white')
pwm_label_state = Label(pwm_frame, fg='red')

pwm_label_image.grid(row=0, column=0)
pwm_btn.grid(row=0, column=1)
pwm_label.grid(row=2, column=0)
pwm_slider.grid(row=3, column=0)
pwm_label_state.grid(row=3, column=1)

inter = setInterval(2, check_exit)
root.mainloop()
