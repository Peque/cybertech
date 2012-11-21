EESchema Schematic File Version 2  date Wed 21 Nov 2012 02:47:28 AM CET
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
LIBS:heracles-cache
EELAYER 25  0
EELAYER END
$Descr A4 11700 8267
encoding utf-8
Sheet 3 6
Title ""
Date "21 nov 2012"
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text HLabel 8000 4800 2    60   Output ~ 0
GND
Text HLabel 8000 3200 2    60   Output ~ 0
3V3
Text HLabel 3100 4800 0    60   Input ~ 0
VBAT-
Text HLabel 3100 4100 0    60   Input ~ 0
VBAT+
Wire Wire Line
	3100 4800 8000 4800
Connection ~ 7550 3200
Connection ~ 7550 4800
Wire Wire Line
	7550 4250 7550 4800
Connection ~ 3650 4800
Wire Wire Line
	3650 4800 3650 4650
Wire Wire Line
	3650 4100 3650 4250
Wire Wire Line
	4150 3600 4000 3600
Wire Wire Line
	4000 3600 4000 3800
Wire Wire Line
	4000 3800 5100 3800
Wire Wire Line
	4900 4300 6650 4300
Wire Wire Line
	4900 4300 4900 3900
Wire Wire Line
	4900 3900 5100 3900
Connection ~ 6650 3800
Wire Wire Line
	6450 3800 6650 3800
Wire Wire Line
	6550 3200 6550 3500
Wire Wire Line
	5000 3500 5000 3200
Wire Wire Line
	6550 4200 5000 4200
Wire Wire Line
	6550 4200 6550 3600
Wire Wire Line
	6550 3600 6450 3600
Wire Wire Line
	5100 3700 5000 3700
Wire Wire Line
	5000 3700 5000 4200
Wire Wire Line
	5000 3500 5100 3500
Wire Wire Line
	6550 3500 6450 3500
Wire Wire Line
	6450 3700 6650 3700
Wire Wire Line
	6650 3700 6650 4300
Wire Wire Line
	6450 3900 6650 3900
Connection ~ 6650 3900
Wire Wire Line
	4750 3600 5100 3600
Connection ~ 4900 4100
Wire Wire Line
	3100 4100 4900 4100
Connection ~ 3650 4100
Wire Wire Line
	5750 4800 5750 4200
Connection ~ 5750 4200
Connection ~ 5750 4800
Wire Wire Line
	5000 3200 8000 3200
Connection ~ 6550 3200
Wire Wire Line
	7550 3850 7550 3200
$Comp
L C C3
U 1 1 50A32A89
P 7550 4050
F 0 "C3" H 7600 4150 50  0000 L CNN
F 1 "22uF" H 7600 3950 50  0000 L CNN
F 2 "SM0603" H 7550 4050 60  0001 C CNN
	1    7550 4050
	1    0    0    -1  
$EndComp
$Comp
L C C2
U 1 1 50A32A51
P 3650 4450
F 0 "C2" H 3700 4550 50  0000 L CNN
F 1 "10uF" H 3700 4350 50  0000 L CNN
F 2 "SM0603" H 3650 4450 60  0001 C CNN
	1    3650 4450
	1    0    0    -1  
$EndComp
$Comp
L INDUCTOR L1
U 1 1 50A3299E
P 4450 3600
F 0 "L1" V 4400 3600 40  0000 C CNN
F 1 "2.2uH" V 4550 3600 40  0000 C CNN
F 2 "NRS4018T2R2MDGJ" H 4450 3600 60  0001 C CNN
	1    4450 3600
	0    -1   -1   0   
$EndComp
$Comp
L TPS63031 U3
U 1 1 50A3243C
P 5750 3700
F 0 "U3" H 5500 4050 60  0000 C CNN
F 1 "TPS63031" H 5800 3300 60  0000 C CNN
F 2 "QFN10" H 5750 3700 60  0001 C CNN
	1    5750 3700
	1    0    0    -1  
$EndComp
$EndSCHEMATC
