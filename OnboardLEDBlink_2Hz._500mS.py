'''
Description: Onboard LED Blink Program.
Author     : M.Pugazhendi
Date       : 06thMar2021

A. Intialize timer_one, trigger LED blink period to 500mSec.

'''

from machine import Pin, Timer
led = Pin(25, Pin.OUT)
timer = Timer()

def blink(timer):
    led.toggle()

timer.init(freq=2, mode=Timer.PERIODIC, callback=blink)
