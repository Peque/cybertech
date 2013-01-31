EESchema Schematic File Version 2  date Thu 31 Jan 2013 03:21:04 PM CET
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:special
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:reset
EELAYER 43  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 1 1
Title ""
Date "31 jan 2013"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Connection ~ 6050 4100
Wire Wire Line
	6050 4100 6050 4500
Wire Wire Line
	6050 4500 5200 4500
Wire Wire Line
	5850 4000 6300 4000
Wire Wire Line
	5850 3800 6300 3800
Wire Wire Line
	5850 3700 6300 3700
Wire Wire Line
	5850 3900 6300 3900
Wire Wire Line
	5850 4100 6300 4100
$Comp
L CONN_5 P1
U 1 1 510A7B15
P 6700 3900
F 0 "P1" V 6650 3900 50  0000 C CNN
F 1 "CONN_5" V 6750 3900 50  0000 C CNN
F 2 "SIL-5" H 6700 3900 60  0001 C CNN
	1    6700 3900
	1    0    0    -1  
$EndComp
$Comp
L USB2-MINI/MICRO J1
U 1 1 510A7AAB
P 5300 3900
F 0 "J1" H 5500 3550 60  0000 C CNN
F 1 "USB2-MINI/MICRO" H 5300 4250 60  0000 C CNN
F 2 "USB_Micro-B" H 5300 3900 60  0001 C CNN
	1    5300 3900
	1    0    0    -1  
$EndComp
$EndSCHEMATC
